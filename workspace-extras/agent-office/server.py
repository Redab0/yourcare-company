#!/usr/bin/env python3
"""Read-only, loopback-only view of local Codex activity. No extra packages."""
import argparse
import json
import os
import sqlite3
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

HERE = Path(__file__).resolve().parent
COLORS = ["#168879", "#dc8652", "#7d79b8", "#548ec0", "#bf708d", "#94964e"]
ACTIVE = {"inProgress", "in_progress", "running", "active"}


def connect(path):
    con = sqlite3.connect(path.resolve().as_uri() + "?mode=ro", uri=True, timeout=2)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA query_only=ON")
    return con


def activity(item):
    kind = item.get("type", "")
    if kind == "commandExecution":
        actions = item.get("commandActions") or []
        if any(a.get("type") == "read" for a in actions):
            return "Reading project files", "reading"
        if any(a.get("type") == "search" for a in actions):
            return "Searching the codebase", "reading"
        return "Running a command", "working"
    if kind == "fileChange":
        return "Editing project files", "working"
    if kind == "webSearch":
        return "Researching on the web", "reading"
    if kind == "mcpToolCall":
        return "Using a connected tool", "working"
    if kind == "subAgentActivity":
        return "Coordinating with an agent", "working"
    if kind in {"reasoning", "plan"}:
        return "Thinking through the task", "thinking"
    if kind == "agentMessage":
        return "Writing an update", "working"
    return "Working on the task", "working"


def root_for(thread_id, parents):
    seen = set()
    while thread_id in parents and thread_id not in seen:
        seen.add(thread_id)
        thread_id = parents[thread_id]
    return thread_id


def history_rows(history, thread_id, fingerprint, cache=None):
    """Read a thread only when its persisted projection or metadata changes."""
    cached = cache.get(thread_id) if cache is not None else None
    if cached and cached[0] == fingerprint:
        return cached[1]
    turn = history.execute(
        "SELECT * FROM thread_turns WHERE thread_id=? ORDER BY rollout_ordinal DESC LIMIT 1", (thread_id,)
    ).fetchone()
    items = history.execute(
        "SELECT item_id,item_type,item_json,created_at_ms,completed_at_ms FROM thread_items WHERE thread_id=? ORDER BY rollout_ordinal DESC LIMIT 16", (thread_id,)
    ).fetchall()
    collaborations = history.execute(
        "SELECT item_id,item_json,created_at_ms,completed_at_ms FROM thread_items WHERE thread_id=? AND item_type='subAgentActivity' ORDER BY rollout_ordinal DESC LIMIT 20", (thread_id,)
    ).fetchall()
    result = (turn, items, collaborations)
    if cache is not None:
        cache[thread_id] = (fingerprint, result)
    return result


def snapshot(codex_home, now=None, cache=None):
    now = time.time() if now is None else now
    state_path = codex_home / "state_5.sqlite"
    history_path = codex_home / "thread_history_1.sqlite"
    if not state_path.exists() or not history_path.exists():
        raise RuntimeError("Local Codex activity databases were not found. Start Codex on this Mac first.")
    state, history = connect(state_path), connect(history_path)
    try:
        rows = state.execute("SELECT * FROM threads WHERE archived=0 ORDER BY updated_at DESC").fetchall()
        parents = {r["child_thread_id"]: r["parent_thread_id"] for r in state.execute("SELECT * FROM thread_spawn_edges")}
        # The projection watermark advances for new events and updates to existing items.
        # Never create an index or change Codex's databases for this local observer.
        watermarks = {}
        if cache is not None:
            try:
                watermarks = dict(history.execute("SELECT thread_id,next_rollout_ordinal FROM thread_history_projection_state"))
            except sqlite3.OperationalError:
                cache = None  # Older stores without watermarks must always be read afresh.
        if cache is not None:
            visible_ids = {r['id'] for r in rows}
            for stale_id in list(cache):
                if stale_id not in visible_ids:
                    del cache[stale_id]
        agents, interactions, events = [], [], []
        for row in rows:
            d = dict(row)
            if d.get("thread_source") in {"guardian_review", "memory_consolidation"}:
                continue
            # Older stores encode ancestry in source instead of thread_spawn_edges.
            try:
                source = json.loads(d.get("source", "{}"))
                parent = source.get("subagent", {}).get("thread_spawn", {}).get("parent_thread_id")
                if parent:
                    parents[d["id"]] = parent
            except (ValueError, AttributeError):
                pass
            fingerprint = (str(codex_home.resolve()), d.get('updated_at_ms'), d.get('updated_at'), watermarks.get(d['id']))
            turn, last_items, collaborations = history_rows(history, d['id'], fingerprint, cache)
            # Reasoning is classified by type only; its text is never sent to the page.
            recent = json.loads(last_items[0]["item_json"]) if last_items else {}
            latest_ms = max((i["completed_at_ms"] or i["created_at_ms"] or 0 for i in last_items), default=0)
            updated = max(float(d.get("updated_at") or 0), latest_ms / 1000)
            status = turn["status"] if turn else "unknown"
            if status in ACTIVE:
                label, visual = activity(recent)
                # A process can disappear before persisting completion. Do not call it idle.
                if now - updated > 600:
                    label, visual = "No recent activity · status uncertain", "unknown"
            elif status == "failed":
                label, visual = "Task encountered an error", "error"
            elif status == "interrupted":
                label, visual = "Task interrupted", "idle"
            elif status == "completed":
                label, visual = "Finished · ready for the next task", "idle"
            else:
                label, visual = "No activity recorded", "unknown"
            # Detect approval and input requests from public item metadata.
            if status in ACTIVE and (recent.get("status") in {"awaitingApproval", "pendingApproval"} or recent.get("questions")):
                label, visual = "Waiting for your input", "waiting"
            agents.append({
                "id": d["id"], "name": d.get("name") or d.get("agent_nickname") or d.get("title") or "Untitled agent",
                "nickname": d.get("agent_nickname"), "path": d.get("agent_path") or "/root",
                "project": Path(d.get("cwd") or "Local workspace").name,
                "status": visual, "activity": label, "updated": updated,
                "active": status in ACTIVE, "recent": now - updated < 86400,
                "role": d.get("agent_role") or ("Child agent" if d.get("agent_path") else "Task agent"),
            })
            for i in last_items[:5]:
                if i["item_type"] in {"reasoning", "userMessage"}:
                    continue
                item = json.loads(i["item_json"])
                text, _ = activity(item)
                stamp = (i["completed_at_ms"] or i["created_at_ms"] or 0) / 1000
                if stamp:
                    events.append({"id": d["id"] + i["item_id"], "agentId": d["id"], "text": text, "time": stamp})
            # Messages between user-owned local chats are projected as MCP calls.
            for i in last_items:
                if i["item_type"] != "mcpToolCall":
                    continue
                item = json.loads(i["item_json"])
                if item.get("tool") not in {"send_message_to_thread", "mcp__codex_app__send_message_to_thread"} or item.get("status") != "completed":
                    continue
                result = item.get("result") or {}
                if item.get("error") or (isinstance(result, dict) and result.get("isError")):
                    continue
                args = item.get("arguments") or {}
                target = args.get("threadId") if isinstance(args, dict) else None
                if target:
                    stamp = (i["completed_at_ms"] or i["created_at_ms"] or 0) / 1000
                    interactions.append({"id": d["id"] + i["item_id"], "from": d["id"], "to": target, "time": stamp, "text": "Chat message"})
            # Projected collaboration items carry exact recipient IDs; no guessing from task names.
            for i in collaborations:
                item = json.loads(i["item_json"])
                if item.get("kind") != "interacted" or not item.get("agentThreadId"):
                    continue
                stamp = (i["completed_at_ms"] or i["created_at_ms"] or 0) / 1000
                interactions.append({"id": d["id"] + i["item_id"], "from": d["id"], "to": item["agentThreadId"], "time": stamp, "text": "Agent message"})
        ids = {a["id"] for a in agents}
        interactions = [m for m in interactions if m["to"] in ids]
        for a in agents:
            a["rootId"] = root_for(a["id"], parents)
            a["parentId"] = parents.get(a["id"])
            a["color"] = COLORS[sum(a["id"].encode()) % len(COLORS)]
        # A meeting is a 45-second visual window after a recorded message, not a claim
        # that two agents spend 45 seconds in a synchronous conversation.
        meetings = [m for m in interactions if 0 <= now - m["time"] < 45]
        return {
            "source": "local-codex", "generatedAt": now, "agents": agents,
            "meetings": sorted(meetings, key=lambda x: x["time"], reverse=True),
            "messages": sorted(interactions, key=lambda x: x["time"], reverse=True)[:100],
            "events": sorted(events, key=lambda x: x["time"], reverse=True)[:60],
            "meetingWindow": 45, "pollSeconds": 2,
        }
    finally:
        state.close()
        history.close()


class Handler(BaseHTTPRequestHandler):
    codex_home = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
    activity_cache = {}
    activity_lock = threading.Lock()

    def do_GET(self):
        host = self.headers.get("Host", "").split(":")[0]
        if host not in {"127.0.0.1", "localhost"}:
            self.send_error(403)
            return
        origin = self.headers.get("Origin")
        if origin and urlparse(origin).netloc != self.headers.get("Host"):
            self.send_error(403)
            return
        path = urlparse(self.path).path
        if path == "/api/health":
            self.respond(b'{"status":"ok","service":"robot-office"}', "application/json")
            return
        if path == "/api/state":
            try:
                with self.activity_lock:
                    data = snapshot(self.codex_home, cache=self.activity_cache)
            except (sqlite3.Error, RuntimeError, OSError, ValueError) as exc:
                self.respond(json.dumps({"error": str(exc)}).encode(), "application/json", 503)
            else:
                self.respond(json.dumps(data).encode(), "application/json")
            return
        assets = {"/": ("index.html", "text/html"), "/index.html": ("index.html", "text/html"),
                  "/style.css": ("style.css", "text/css"), "/app.js": ("app.js", "text/javascript")}
        if path not in assets:
            self.send_error(404)
            return
        name, mime = assets[path]
        self.respond((HERE / name).read_bytes(), mime)

    def respond(self, body, mime, code=200):
        self.send_response(code)
        self.send_header("Content-Type", mime + "; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Content-Security-Policy", "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'self'")
        try:
            self.end_headers()
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass  # A closed browser tab is not an activity-feed or service failure.

    def log_message(self, *_):
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--codex-home", type=Path, default=Handler.codex_home)
    args = parser.parse_args()
    Handler.codex_home = args.codex_home
    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    print(f"Robot office is live at http://127.0.0.1:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
