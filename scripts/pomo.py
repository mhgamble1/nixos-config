import os
import sys
import signal
import time

STATE_DIR = os.path.expanduser("~/.local/share/pomo")
STATE_FILE = os.path.join(STATE_DIR, "state")
PID_FILE = os.path.join(STATE_DIR, "pid")

BLUE = "\033[34m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RESET = "\033[0m"


def read_state():
    try:
        with open(STATE_FILE) as f:
            parts = f.read().strip().split(" ", 1)
        return int(parts[0]), parts[1] if len(parts) > 1 else "Work"
    except (FileNotFoundError, ValueError):
        return None, None


def clear_state():
    for path in (STATE_FILE, PID_FILE):
        try:
            os.unlink(path)
        except FileNotFoundError:
            pass


def kill_existing():
    try:
        with open(PID_FILE) as f:
            pid = int(f.read().strip())
        os.kill(pid, signal.SIGTERM)
    except (FileNotFoundError, ProcessLookupError, ValueError):
        pass


def cmd_status():
    deadline, label = read_state()
    if deadline is None:
        print("[pomo] no active session")
        return
    rem = deadline - int(time.time())
    if rem <= 0:
        print("[pomo] no active session")
        clear_state()
        return
    m, s = divmod(rem, 60)
    print(f"{BLUE}[pomo]{RESET} {label} \u2014 {m:02d}:{s:02d} remaining")


def cmd_stop():
    deadline, _ = read_state()
    if deadline is None:
        print("[pomo] no active session")
        return
    kill_existing()
    clear_state()
    print(f"{YELLOW}[pomo]{RESET} cancelled")


def notify(label, env):
    try:
        import subprocess
        subprocess.run(
            ["notify-send", "Pomodoro", f"{label} complete", "-t", "5000"],
            env=env,
            capture_output=True,
        )
    except FileNotFoundError:
        pass


def cmd_start(duration, label):
    kill_existing()
    os.makedirs(STATE_DIR, exist_ok=True)

    total = duration * 60
    deadline = int(time.time()) + total

    with open(STATE_FILE, "w") as f:
        f.write(f"{deadline} {label}")

    # Snapshot full env before forking so the daemon inherits PATH, D-Bus, etc.
    notify_env = dict(os.environ)

    pid = os.fork()
    if pid == 0:
        # Daemon child: detach from terminal, sleep, then notify
        os.setsid()
        null = os.open(os.devnull, os.O_RDWR)
        for fd in (0, 1, 2):
            os.dup2(null, fd)
        os.close(null)

        time.sleep(total)
        notify(label, notify_env)
        clear_state()
        os._exit(0)

    # Parent: record PID and return immediately
    with open(PID_FILE, "w") as f:
        f.write(str(pid))

    print(f"{BLUE}[pomo]{RESET} {label} \u2014 {duration} min (running in background)")  # noqa: E501


def main():
    args = sys.argv[1:]

    if not args:
        cmd_start(25, "Work")
        return

    sub = args[0]

    if sub == "status":
        cmd_status()
    elif sub in ("stop", "cancel"):
        cmd_stop()
    elif sub == "break":
        cmd_start(5, "Short Break")
    elif sub == "long":
        cmd_start(15, "Long Break")
    elif sub in ("-h", "--help"):
        print("Usage: pomo [break|long|<minutes>|status|stop]")
        print("  (no args)   25-min work session")
        print("  break        5-min short break")
        print("  long        15-min long break")
        print("  <n>          n-min custom timer")
        print("  status       show time remaining")
        print("  stop         cancel active session")
    else:
        try:
            duration = int(sub)
            if duration <= 0:
                raise ValueError
            cmd_start(duration, "Work")
        except ValueError:
            print(f"[pomo] unknown argument: {sub}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
