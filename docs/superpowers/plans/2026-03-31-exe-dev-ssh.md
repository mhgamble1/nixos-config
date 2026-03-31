# exe.dev SSH Connection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the brittle two-hop exe.dev SSH workflow with direct SSH connections featuring keepalives, ControlMaster multiplexing, and invisible tmux session persistence.

**Architecture:** A wildcard SSH `matchBlock` in `home/mhg/default.nix` applies keepalives and ControlMaster to all exe.dev VMs. A generic `exe` Fish function in `modules/terminal.nix` connects directly and attaches-or-creates a tmux session. The tmux status bar is hidden — session persistence is invisible to the user.

**Tech Stack:** NixOS Home Manager (`programs.ssh`, `programs.tmux`, `programs.fish`), OpenSSH, tmux

---

### Task 1: Discover exe.dev VM hostname and username

**Files:**
- No changes — discovery only

- [ ] **Step 1: List VMs from the exe.dev management CLI**

Connect to exe.dev and list VMs:

```
ssh exe.dev
exe.dev ▶ ls
```

Note the output format for VM addresses. You'll see one of:
- Hostnames like `my-vm.exe.dev` → the SSH `Host` pattern will be `"*.exe.dev"`
- Short names like `my-vm` with a separate IP column → record the IP for direct use; `Host` pattern TBD
- Just IPs → the SSH matchBlock `Host` pattern does not apply; `exe` function will pass options inline

- [ ] **Step 2: Note the SSH username**

Still in the management CLI, SSH into a VM and check the prompt:

```
exe.dev ▶ ssh my-server
```

Note the username shown (e.g. `ubuntu`, `user`, `root`). This goes in the matchBlock.

- [ ] **Step 3: Exit**

```
exe.dev ▶ exit
```

---

### Task 2: Add SSH matchBlock for exe.dev VMs

**Files:**
- Modify: `home/mhg/default.nix:26-34`

This block makes keepalives and ControlMaster apply automatically to all matching connections.

**Skip this task** if Task 1 revealed that VMs are only reachable by raw IP with no consistent hostname pattern — the `exe` function in Task 4 will handle those inline.

- [ ] **Step 1: Add the matchBlock after the `hermes` block**

In `home/mhg/default.nix`, replace:

```nix
    # Hermes VPS — AI agent / remote workspace
    matchBlocks."hermes" = {
      hostname = secrets.hermes.hostname;
      user = secrets.hermes.user;
      identityFile = "~/.ssh/id_ed25519";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };
  };
```

with:

```nix
    # Hermes VPS — AI agent / remote workspace
    matchBlocks."hermes" = {
      hostname = secrets.hermes.hostname;
      user = secrets.hermes.user;
      identityFile = "~/.ssh/id_ed25519";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };
    # exe.dev VMs — direct SSH with keepalives and connection multiplexing
    # Replace "*.exe.dev" with the actual host pattern from Task 1.
    # Replace "ubuntu" with the actual username from Task 1.
    matchBlocks."*.exe.dev" = {
      user = "ubuntu";
      identityFile = "~/.ssh/id_ed25519";
      serverAliveInterval = 30;
      serverAliveCountMax = 6;
      extraOptions = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h:%p";
        ControlPersist = "10m";
      };
    };
  };
```

- [ ] **Step 2: Verify Nix syntax**

```
nix-instantiate --parse /etc/nixos/home/mhg/default.nix > /dev/null && echo OK
```

Expected: `OK` with no errors.

---

### Task 3: Hide tmux status bar

**Files:**
- Modify: `modules/terminal.nix:179-188`

Add `set -g status off` at the top of the status bar section. The color config stays so it looks right if toggled back on manually with `tmux set status on`.

- [ ] **Step 1: Add `set -g status off`**

In `modules/terminal.nix`, replace:

```nix
      # Status bar (minimal, Tokyo Night colors)
      set -g status-style bg='#1a1b26',fg='#c0caf5'
```

with:

```nix
      # Status bar (minimal, Tokyo Night colors) — hidden by default
      # To show temporarily: tmux set status on
      set -g status off
      set -g status-style bg='#1a1b26',fg='#c0caf5'
```

- [ ] **Step 2: Verify Nix syntax**

```
nix-instantiate --parse /etc/nixos/modules/terminal.nix > /dev/null && echo OK
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add modules/terminal.nix
git commit -m "feat: hide tmux status bar by default"
```

---

### Task 4: Add generic `exe` Fish function

**Files:**
- Modify: `modules/terminal.nix:266-273`

The function takes one argument (VM hostname or IP), connects directly, and attaches-or-creates a tmux session named `main`. SSH options are passed inline so this works even when no matchBlock covers the host (i.e. raw IPs). When a matchBlock does match, SSH merges both — no conflict.

- [ ] **Step 1: Add the `exe` function after the `hermes` function**

In `modules/terminal.nix`, replace:

```nix
      # SSH into Hermes VPS and attach-or-create the persistent tmux session.
      # Requires the 'hermes' SSH host block configured in programs.ssh (home.nix).
      hermes = {
        description = "Attach to Hermes AI agent on VPS (tmux session: hermes)";
        body = ''ssh -t hermes "tmux new-session -A -s hermes"'';
      };

    };
```

with:

```nix
      # SSH into Hermes VPS and attach-or-create the persistent tmux session.
      # Requires the 'hermes' SSH host block configured in programs.ssh (home.nix).
      hermes = {
        description = "Attach to Hermes AI agent on VPS (tmux session: hermes)";
        body = ''ssh -t hermes "tmux new-session -A -s hermes"'';
      };

      # Connect to an exe.dev VM directly, with keepalives, ControlMaster, and
      # tmux session persistence. Usage: exe <hostname-or-ip>
      # Reconnecting after a drop reattaches the same session — state is preserved.
      exe = {
        description = "Connect to an exe.dev VM with tmux session persistence";
        body = ''
          if test (count $argv) -ne 1
            echo "Usage: exe <hostname-or-ip>"
            return 1
          end
          ssh -t \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=6 \
            -o ControlMaster=auto \
            -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
            -o ControlPersist=10m \
            $argv[1] "tmux new-session -A -s main"
        '';
      };

    };
```

- [ ] **Step 2: Verify Nix syntax**

```
nix-instantiate --parse /etc/nixos/modules/terminal.nix > /dev/null && echo OK
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add home/mhg/default.nix modules/terminal.nix
git commit -m "feat: add exe.dev SSH config and exe Fish function"
```

---

### Task 5: Apply config and verify

**Files:**
- No changes

- [ ] **Step 1: Rebuild**

```
nrs
```

Expected: completes with no errors.

- [ ] **Step 2: Verify SSH config (if matchBlock was added)**

```
grep -A 12 "exe.dev" ~/.ssh/config
```

Expected: block showing the host pattern, user, `ServerAliveInterval 30`, `ControlMaster auto`, `ControlPath`.

- [ ] **Step 3: Test basic connection**

```
exe my-server   # replace with actual hostname or IP from Task 1
```

Expected: connects, drops into a shell with no tmux status bar visible.

- [ ] **Step 4: Test session persistence**

While connected, run a background process:

```bash
sleep 300 &
```

Kill the SSH connection (close the Ghostty tab, or press `~.`). Reconnect:

```
exe my-server
```

Expected: reattaches to the same tmux session. Run `jobs` — `sleep 300` is still running.

- [ ] **Step 5: Test ControlMaster (if matchBlock added)**

Open a second Ghostty window and connect to the same VM again:

```
exe my-server
```

Expected: connects noticeably faster than the first time (reusing the existing TCP socket).

- [ ] **Step 6: Final commit if any stray changes**

```bash
git status
# If clean, nothing to do. If there are uncommitted changes:
git add -p
git commit -m "chore: clean up after exe.dev SSH setup"
```
