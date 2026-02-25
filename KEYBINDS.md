# Keybind Reference

Working document for reviewing keybindings across the full stack.
This file is the source of truth. Update it whenever binds change.

**Keyboard:** Glove80 with Tailorkey 4.2m bilateral homerow mods
- Left homerow hold:  A=Super, S=Alt, D=Ctrl, F=Shift
- Right homerow hold: J=Shift, K=Ctrl, L=Alt, ;=Super
- Bilateral: modifier only fires when key is on opposite hand
- **Status (2026-02):** Committing to HRM — thumb-SUPER disabled in Tailorkey for the trial period

---

## Design Philosophy

- **Hyprland owns layout.** Windows, splits, and workspaces live at the WM level. tmux and Ghostty do not split.
- **tmux is SSH-only.** Use it when connecting to remote machines; not as a local navigation layer.
- **One modifier, one domain.** `SUPER` = WM operations. Everything else is modal or app-native.
- **hjkl is universal.** Navigation uses vim keys wherever possible: WM focus, editor movement, shell vi mode.

---

## Hyprland

**Modifier:** `$mod = SUPER`

### Applications
| Binding | Action |
|---------|--------|
| `SUPER+Return` | Terminal (Ghostty) |
| `SUPER+D` | App launcher (Fuzzel) |
| `SUPER+E` | File manager (Yazi, floating) |
| `SUPER+M` | Music (spotify-player, floating) |
| `SUPER+/` | Cheatsheet (bat, floating) |

### Window Management
| Binding | Action |
|---------|--------|
| `SUPER+Q` | Close active window |
| `SUPER+F` | Toggle fullscreen |
| `SUPER+SHIFT+F` | Toggle floating |
| `SUPER+P` | Pseudotile (float within tile) |
| `SUPER+S` | Toggle split direction |

### Focus
| Binding | Action |
|---------|--------|
| `SUPER+h` | Focus left |
| `SUPER+l` | Focus right |
| `SUPER+k` | Focus up |
| `SUPER+j` | Focus down |

### Move Windows
| Binding | Action |
|---------|--------|
| `SUPER+SHIFT+h` | Move window left |
| `SUPER+SHIFT+l` | Move window right |
| `SUPER+SHIFT+k` | Move window up |
| `SUPER+SHIFT+j` | Move window down |

### Workspaces
| Binding | Action |
|---------|--------|
| `SUPER+1` | Switch to `code` |
| `SUPER+2` | Switch to `web` |
| `SUPER+3` | Switch to `comms` |
| `SUPER+4` | Switch to `music` |
| `SUPER+5` | Switch to `scratch` |
| `SUPER+6…9` | Switch to workspace 6–9 (unnamed) |
| `SUPER+SHIFT+1…9` | Move window to workspace 1–9 |
| `SUPER+Tab` | Toggle most recent workspace |
| `SUPER+scroll` | Cycle workspaces |

### Media & System
| Binding | Action |
|---------|--------|
| `XF86AudioMute` | Toggle mute |
| `XF86AudioRaiseVolume` | Volume +5% (repeatable) |
| `XF86AudioLowerVolume` | Volume -5% (repeatable) |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86MonBrightnessUp` | Brightness +5% (repeatable) |
| `XF86MonBrightnessDown` | Brightness -5% (repeatable) |

### Screenshots & Recording
| Binding | Action |
|---------|--------|
| `SUPER+SHIFT+S` | Screenshot region selection |
| `SUPER+SHIFT+P` | Full screenshot |
| `SUPER+SHIFT+W` | Toggle screen recording (→ ~/Videos) |

### System
| Binding | Action |
|---------|--------|
| `SUPER+SHIFT+L` | Lock screen (swaylock) |
| `SUPER+SHIFT+R` | Reload Hyprland config |
| `SUPER+SHIFT+E` | Exit / logout |

### Mouse
| Binding | Action |
|---------|--------|
| `SUPER+LMB drag` | Move floating window |
| `SUPER+RMB drag` | Resize window |

### Known Gaps
- No keyboard-driven window resize (submap would solve this)
- Workspaces 6–9 unnamed
- No scratchpad / special workspace

---

## tmux (SSH use only)

**Prefix:** `Ctrl+a`

tmux is not auto-started locally. Launch it manually when SSHing to a remote machine.
All local layout is handled by Hyprland — no tmux splits in local sessions.

### Panes (remote use)
| Binding | Action |
|---------|--------|
| `PREFIX+\|` | Split right |
| `PREFIX+-` | Split down |
| `PREFIX+h/j/k/l` | Navigate panes |
| `PREFIX+H/J/K/L` | Resize pane (5 units, repeatable) |
| `PREFIX+z` | Zoom pane |
| `PREFIX+x` | Close pane |
| `Alt+o` | Cycle panes (no prefix) |

### Windows / Sessions
| Binding | Action |
|---------|--------|
| `PREFIX+c` | New window |
| `PREFIX+n/p` | Next/previous window |
| `PREFIX+1…9` | Jump to window |
| `PREFIX+$` | Rename session |
| `PREFIX+s` | Choose session |
| `PREFIX+d` | Detach |

### Copy Mode
| Binding | Action |
|---------|--------|
| `PREFIX+[` | Enter copy mode |
| `q` | Exit copy mode |
| `/` | Search |
| `Space` / `Enter` | Start / copy selection |

---

## Ghostty

Ghostty is used as a plain terminal emulator. Splits are disabled — use Hyprland windows instead.

### Tabs (if needed)
Ghostty's built-in tab support is available via the GTK tab bar. No custom keybinds configured.

---

## Helix

**Modes:** Normal → Insert (`i`), Normal → Select (`v`), Normal → Command (`:`)

### Movement (Normal mode)
| Binding | Action |
|---------|--------|
| `h/j/k/l` | Character/line movement |
| `w/b/e` | Word forward/back/end |
| `W/B/E` | WORD forward/back/end |
| `f/t` + char | Find/till char on line |
| `F/T` + char | Find/till char backwards |
| `gg` / `G` | Start / end of file |
| `{` / `}` | Previous / next paragraph |
| `Ctrl+u/d` | Scroll half-page up/down |
| `%` | Select entire file |

### Selection
| Binding | Action |
|---------|--------|
| `v` | Enter select mode |
| `x` | Select line |
| `C` | Copy selection down |
| `Alt+s` | Split selection on newlines |

### Editing
| Binding | Action |
|---------|--------|
| `i/a` | Insert before/after |
| `I/A` | Insert at line start/end |
| `o/O` | Open line below/above |
| `d` | Delete (yank) |
| `c` | Change (delete + insert) |
| `y` | Yank |
| `p/P` | Paste after/before |
| `u` / `U` | Undo / Redo |
| `~` | Toggle case |
| `Ctrl+a/x` | Increment/decrement number |

### Search
| Binding | Action |
|---------|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n/N` | Next/previous match |
| `*` | Search word under cursor |

### File / Buffer
| Binding | Action |
|---------|--------|
| `Space+f` | File picker |
| `Space+b` | Buffer picker |
| `Space+/` | Global search (grep) |
| `Space+s` | Symbol picker |
| `Ctrl+w` + `h/j/k/l` | Navigate splits |
| `Ctrl+w` + `v/s` | Vertical/horizontal split |
| `:w` / `:q` / `:wq` | Save / quit / save+quit |

### LSP
| Binding | Action |
|---------|--------|
| `Space+d` | Diagnostics picker |
| `Space+k` | Hover documentation |
| `gd` | Go to definition |
| `gr` | Go to references |
| `Space+r` | Rename symbol |
| `Space+a` | Code action |
| `]d / [d` | Next/prev diagnostic |

---

## Fish Shell (vi mode)

### Readline / Navigation
| Binding | Action |
|---------|--------|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+T` | Fuzzy insert file path (fzf) |
| `Alt+C` | Fuzzy cd into directory (fzf) |
| `Esc` | Enter vi normal mode |
| `h/j/k/l` | (vi normal mode) navigate |

### Key Aliases
| Alias | Expands to |
|-------|-----------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -lah --icons --group-directories-first --git` |
| `la` | `eza -lah --icons --group-directories-first` |
| `lt` | `eza --tree --icons --level=2` |
| `lta` | `eza --tree --icons --level=2 -a` |
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `cat` | `bat` |
| `diff` | `difft` |
| `du` | `dust` |
| `df` | `duf` |
| `ps` | `procs` |
| `top` | `btm` |
| `nrs` | `sudo nixos-rebuild switch` |
| `nrsu` | `sudo nixos-rebuild switch --upgrade` |
| `nrb` | `sudo nixos-rebuild boot` |
| `ne` | `sudoedit /etc/nixos/configuration.nix` |
| `nhm` | `sudoedit /etc/nixos/home.nix` |

---

## Cross-Tool Consistency Map

| Concept | Hyprland | tmux (SSH) | Helix | Fish vi |
|---------|----------|------------|-------|---------|
| Move left | `SUPER+h` | `PREFIX+h` | `h` | `h` |
| Move right | `SUPER+l` | `PREFIX+l` | `l` | `l` |
| Move up | `SUPER+k` | `PREFIX+k` | `k` | `k` |
| Move down | `SUPER+j` | `PREFIX+j` | `j` | `j` |
| Split right | new window | `PREFIX+\|` | `Ctrl+w v` | — |
| Split down | new window | `PREFIX+-` | `Ctrl+w s` | — |
| Close | `SUPER+Q` | `PREFIX+x` | `:q` | — |
| Search | — | `PREFIX+[` then `/` | `/` | `Ctrl+R` |
| Fullscreen | `SUPER+F` | `PREFIX+z` | — | — |

---

## Optimization Backlog

### Near-term
- [ ] **Keyboard resize submap** — `SUPER+R` enters resize mode, `hjkl` resize, `Esc` exits
- [ ] **Name workspaces 6–9** if they get regular use
- [ ] **Scratchpad** — `SUPER+grave` toggle, `SUPER+SHIFT+grave` send to scratchpad

### Longer-term (keyboard firmware)
- [ ] **Navigation layer in ZMK** — hold thumb key → right hand becomes nav (hjkl, word jump, page scroll) in every app
- [ ] **Review Tailorkey HRM timing** — after trial period, tune tapping-term-ms per finger if needed
- [ ] **Evaluate going fully custom ZMK** vs. staying on Tailorkey

---

## Changelog

### 2026-02 — Layout unification & HRM commitment
- **Removed** tmux auto-attach from Fish login. tmux is now SSH/remote only.
- **Removed** Ghostty split keybinds. Ghostty is a plain terminal; Hyprland owns layout.
- **Added** named workspaces: 1=code, 2=web, 3=comms, 4=music, 5=scratch.
- **Added** `SUPER+Tab` to cycle most recent workspace.
- **Added** media keys: XF86AudioPlay/Next/Prev/Mute, volume ±5% (repeatable), brightness ±5% (repeatable).
- **HRM trial:** Thumb-SUPER disabled in Tailorkey. Committing to bilateral homerow mods for evaluation.
- **Design principle adopted:** Hyprland owns layout; one modifier (SUPER) for WM; everything else is modal.
