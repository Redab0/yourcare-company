# The Robot Office

A dependency-free HTML/CSS/JavaScript office with a small Python server that reads local Codex activity. It is separate from the Flutter driver application.

## Run

On this Mac, run it as a persistent local background service:

```sh
cd /Users/bshaqra/IdeaProjects/cleaning/driver/agent-office
python3 service.py start
```

Open **http://127.0.0.1:8765**. macOS launchd keeps the service independent of the chat or terminal, restarts it after an unexpected exit, and starts it at login. It still listens only on this Mac. The per-user registration is `~/Library/LaunchAgents/local.robot-office.plist`; logs are in the ignored `.runtime/` folder.

```sh
python3 service.py status
python3 service.py restart
python3 service.py stop       # Stop until next login or manual start
python3 service.py uninstall  # Remove the background registration
```

For a temporary foreground session instead, use:

```sh
cd /Users/bshaqra/IdeaProjects/cleaning/driver/agent-office
python3 server.py
```

Stop the foreground server with Ctrl+C. Closing that terminal or its execution session also stops the page; use the background service above for ongoing use. Requires Python 3.9+ and a local Codex installation using `state_5.sqlite` and `thread_history_1.sqlite`. Set `CODEX_HOME`, or pass `--codex-home /path/to/.codex` to `server.py`, to use another local activity directory. Use `--port 8766` if the default port is occupied.

The standalone `index.html` contains the page, with its sibling `app.js` and `style.css`. Live activity requires the Python server; a static HTML file cannot read Codex's local SQLite databases. A clearly labeled fictional preview is available under **How it works → Preview a busy office**. Click the refresh icon to return to live activity.

## How the office behaves

- Agents executing commands, editing files, or thinking occupy workstations. Readers and researchers visit the lab.
- Recorded collaboration messages send the exact sender and recipient to the meeting room for a 45-second animation window. Spawn events alone do not create meetings.
- Completed or interrupted agents rest in the lounge. Input requests and uncertain statuses occupy the waiting area.
- Recent shows the past 24 hours plus every active agent; Working shows active agents and meeting participants; All includes all nonarchived local task agents and child agents. Internal approval reviewers are excluded.
- Eight robots fit on each floor. Floor arrows browse larger teams; the crew list includes the entire selected scope. Click any robot or crew member for details.
- Zoom, expand, search, and animation pause controls are included. Reduced-motion preferences are respected. Pausing visual animation does not pause the activity feed.

## Data boundaries

The server binds only to `127.0.0.1`, checks request origin/host, and opens both databases in SQLite read-only/query-only mode. It never starts, interrupts, or messages an agent. It returns task titles, agent metadata, generic activity labels, timestamps, and communication participants. It never returns private reasoning, command text/output, or message bodies. No external scripts, fonts, images, or APIs are used.

Local database schemas are internal and may change with Codex updates; incompatible stores show a disconnected state. Cloud-only and other-host tasks are outside this local feed. Activity describes persisted events, so it may lag the app briefly. Stale unfinished turns are marked uncertain after ten minutes, rather than reported as idle. “In meetings” means a recently observed message exchange, not a synchronous call.

## Verify

```sh
python3 -m unittest -v
node --check app.js
```

Tests use disposable fixture databases to check active states, meeting recipients/expiry, spawn versus message detection, private-content omission, and enforced read-only database access.
