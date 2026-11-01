#!/usr/bin/env python3
"""Manage the robot office as a per-user macOS background service."""
import argparse
import json
import os
import plistlib
import subprocess
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

HERE = Path(__file__).resolve().parent
LABEL = "local.robot-office"
LAUNCHCTL = "/bin/launchctl"


def configuration(runtime, port=8765):
    codex_home = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))).expanduser().resolve()
    return {
        "Label": LABEL,
        "ProgramArguments": [sys.executable, str(HERE / "server.py"), "--port", str(port), "--codex-home", str(codex_home)],
        "WorkingDirectory": str(HERE),
        "RunAtLoad": True,
        "KeepAlive": True,
        "ThrottleInterval": 10,
        "ProcessType": "Background",
        "StandardOutPath": str(runtime / "server.log"),
        "StandardErrorPath": str(runtime / "server-error.log"),
    }


def belongs_to_office(config):
    return (config.get("Label") == LABEL
            and str(HERE / "server.py") in config.get("ProgramArguments", []))


def launchctl(*args, check=True):
    result = subprocess.run([LAUNCHCTL, *args], capture_output=True, text=True)
    if check and result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "launchctl failed")
    return result


def health(port):
    try:
        with urlopen(f"http://127.0.0.1:{port}/api/health", timeout=1) as response:
            return json.load(response).get("service") == "robot-office"
    except (OSError, ValueError, HTTPError, URLError):
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["start", "restart", "stop", "status", "uninstall"])
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    if sys.platform != "darwin":
        parser.error("This launcher uses macOS launchd. Use python3 server.py on other platforms.")
    domain = f"gui/{os.getuid()}"
    target = f"{domain}/{LABEL}"
    plist_path = Path.home() / "Library" / "LaunchAgents" / f"{LABEL}.plist"
    loaded = launchctl("print", target, check=False).returncode == 0
    existing = plistlib.loads(plist_path.read_bytes()) if plist_path.exists() else None
    if existing and not belongs_to_office(existing):
        raise RuntimeError(f"Refusing to change an unrelated service at {plist_path}")

    if args.action == "status":
        if not loaded:
            print("Robot office service is not loaded.")
            return 1
        print(f"Robot office service is loaded; HTTP {'ready' if health(args.port) else 'not ready'}.")
        print(f"http://127.0.0.1:{args.port}")
        return 0 if health(args.port) else 1

    if args.action in {"stop", "uninstall"}:
        if loaded:
            launchctl("bootout", target)
        if args.action == "uninstall" and existing:
            plist_path.unlink()
        print("Robot office service removed." if args.action == "uninstall" else "Robot office stopped until the next login or manual start.")
        return 0

    runtime = HERE / ".runtime"
    runtime.mkdir(mode=0o700, exist_ok=True)
    config = configuration(runtime, args.port)
    if loaded and (args.action == "restart" or existing != config):
        launchctl("bootout", target)
        loaded = False
    if not loaded:
        if health(args.port):
            raise RuntimeError("An unmanaged robot office is already using this port. Stop it before installing the background service.")
        plist_path.parent.mkdir(parents=True, exist_ok=True)
        plist_path.write_bytes(plistlib.dumps(config))
        plist_path.chmod(0o600)
        launchctl("enable", target)
        launchctl("bootstrap", domain, str(plist_path))
    deadline = time.monotonic() + 12
    while time.monotonic() < deadline:
        if health(args.port):
            print(f"Robot office is running under launchd at http://127.0.0.1:{args.port}")
            print("It runs independently of this chat, restarts after an unexpected exit, and starts at login.")
            print(f"Logs: {runtime}")
            return 0
        time.sleep(0.25)
    raise RuntimeError(f"The service was registered but did not become ready. Check {runtime / 'server-error.log'}.")


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
