{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/hyprland.nix
    ./modules/terminal.nix
    ./modules/dev.nix
    ./modules/theming.nix
  ];

  home.username = "mhg";
  home.homeDirectory = "/home/mhg";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # SSH — GitHub key config
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
  };

  # Git
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Mark Gamble";
      user.email = "mhgamble1@gmail.com";
      init.defaultBranch = "main";
      # Sign commits via SSH key (switch to gpg later if needed)
      gpg.format = "ssh";
      commit.gpgsign = false; # enable once SSH signing key is set
      pull.rebase = false;
    };
  };

  # Git — delta pager for beautiful diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;          # n/N to move between diff sections
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

  # Yazi — TUI file manager
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  # XDG directories
  xdg.enable = true;

  # Default editor
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # ── Cheatsheet ────────────────────────────────────────────────────────
  # Open anytime:  SUPER+/  (floating window)  or  cht  (in terminal)
  home.file."cheatsheet.md".text = ''
    # NixOS + Hyprland — Quick Reference

    **Open anytime:** `SUPER+/` → floating window   |   `cht` → in terminal

    ---

    ## PHASE 1 — SURVIVE  ← start here

    You just logged in. This is everything you need on day one.

    | Key                  | Action                          |
    |----------------------|---------------------------------|
    | `SUPER+ENTER`        | Open terminal (Ghostty)         |
    | `SUPER+D`            | App launcher (wofi)             |
    | `SUPER+Q`            | Close window                    |
    | `SUPER+/`            | This cheatsheet                 |
    | `SUPER+SHIFT+E`      | Exit / logout                   |
    | `SUPER+SHIFT+L`      | Lock screen                     |
    | `SUPER+1` … `SUPER+9`| Switch workspace                |
    | `SUPER+SHIFT+1…9`    | Send window to workspace        |

    That's it. When you're comfortable here, move to Phase 2.

    ---

    ## PHASE 2 — WINDOW MANAGEMENT

    | Key                      | Action                              |
    |--------------------------|-------------------------------------|
    | `SUPER+h/j/k/l`          | Move focus (vim-style)              |
    | `SUPER+SHIFT+h/j/k/l`    | Move window                         |
    | `SUPER+F`                | Fullscreen                          |
    | `SUPER+SHIFT+F`          | Toggle floating                     |
    | `SUPER+S`                | Toggle split direction              |
    | `SUPER+P`                | Pseudotile (float within tile)      |
    | `SUPER+SHIFT+R`          | Reload Hyprland config (no restart) |
    | `SUPER+mouse drag`       | Move floating window                |
    | `SUPER+right-click drag` | Resize window                       |

    ### Screenshots + Recording
    | Key               | Action                                      |
    |-------------------|---------------------------------------------|
    | `SUPER+SHIFT+S`   | Screenshot — select region                  |
    | `SUPER+SHIFT+P`   | Screenshot — full screen                    |
    | `SUPER+SHIFT+W`   | Screen record — toggle (start / stop)       |

    Screenshots save to `~/Pictures/`. Recordings save to `~/Videos/`.

    ---

    ## PHASE 3 — GHOSTTY (terminal)

    Ghostty is the terminal. Most people just use tmux inside it and ignore
    Ghostty's own splits — tmux sessions survive closing the window.

    | Key                  | Action                       |
    |----------------------|------------------------------|
    | `CTRL+SHIFT+T`       | New tab                      |
    | `CTRL+SHIFT+W`       | Close tab                    |
    | `CTRL+SHIFT+1…9`     | Jump to tab N                |
    | `CTRL+SHIFT+\`       | Split right                  |
    | `CTRL+SHIFT+-`       | Split down                   |
    | `CTRL+SHIFT+h/j/k/l` | Navigate panes               |
    | `CTRL+SHIFT+Q`       | Close pane                   |
    | `CTRL+SHIFT+C/V`     | Copy / paste                 |
    | `CTRL+SHIFT+F`       | Find / search                |
    | `CTRL+SHIFT++`       | Increase font size           |
    | `SHIFT+PageUp/Down`  | Scroll                       |

    ---

    ## PHASE 4 — TMUX (multiplexer)

    **Prefix = `Ctrl+a`** (press, release, then the key)

    ### Sessions
    | Command / Key       | Action                          |
    |---------------------|---------------------------------|
    | `tmux`              | New session                     |
    | `tmux attach`       | Reattach to last session        |
    | `PREFIX d`          | Detach (session keeps running)  |
    | `PREFIX $`          | Rename session                  |
    | `PREFIX s`          | Choose session (interactive)    |

    ### Windows (like tabs)
    | Key         | Action                |
    |-------------|-----------------------|
    | `PREFIX c`  | New window            |
    | `PREFIX ,`  | Rename window         |
    | `PREFIX n/p`| Next / previous       |
    | `PREFIX 1…9`| Jump to window N      |
    | `PREFIX &`  | Close window          |

    ### Panes (splits)
    | Key           | Action                        |
    |---------------|-------------------------------|
    | `PREFIX \|`   | Split right                   |
    | `PREFIX -`    | Split down                    |
    | `PREFIX h/j/k/l` | Navigate panes             |
    | `PREFIX H/J/K/L` | Resize panes (repeatable)  |
    | `PREFIX z`    | Zoom pane (fullscreen toggle) |
    | `PREFIX x`    | Close pane                    |

    ### Copy mode (scrollback + search)
    | Key       | Action                   |
    |-----------|--------------------------|
    | `PREFIX [` | Enter copy mode         |
    | `q`        | Exit copy mode          |
    | `/`        | Search                  |
    | `Space`    | Start selection         |
    | `Enter`    | Copy selection          |

    ### Misc
    | Key / Command | Action                  |
    |---------------|-------------------------|
    | `PREFIX r`    | Reload tmux config      |
    | `Alt+o`       | Cycle panes (no prefix) |

    ---

    ## PHASE 5 — FISH (shell)

    Fish uses **vi keybindings**. Default mode is insert (`>`). Press `ESC` for normal (`<`).

    | Key / Command       | Action                                 |
    |---------------------|----------------------------------------|
    | `↑` / `↓`           | History (also `Ctrl+P` / `Ctrl+N`)     |
    | `Ctrl+R`            | Fuzzy history search                   |
    | `Tab`               | Autocomplete (Tab again = menu)        |
    | `Alt+→/←`           | Word forward / backward                |
    | `Ctrl+A` / `Ctrl+E` | Start / end of line                    |
    | `Alt+L`             | Run `ls` in current dir                |
    | `Alt+S`             | Prepend `sudo` to current command      |
    | `Alt+E`             | Open current command in `$EDITOR`      |
    | `cd -`              | Interactive directory history          |

    ### Aliases
    | Alias         | Expands to                              |
    |---------------|-----------------------------------------|
    | `ll` / `la`   | `ls -lah`                               |
    | `..` / `...`  | `cd ..` / `cd ../..`                    |
    | `cat`         | `bat` (prettier output)                 |
    | `gs`          | `git status`                            |
    | `ga`          | `git add`                               |
    | `gc`          | `git commit`                            |
    | `gp`          | `git push`                              |
    | `gl`          | `git log --oneline --graph --decorate`  |
    | `gd`          | `git diff`                              |
    | `nrs`         | `sudo nixos-rebuild switch`             |
    | `nrsu`        | `sudo nixos-rebuild switch --upgrade`   |
    | `nrb`         | `sudo nixos-rebuild boot`               |
    | `ne`          | Edit `configuration.nix`               |
    | `cht`         | View this cheatsheet                    |

    ---

    ## PHASE 6 — YAZI (file manager)

    Launch: `SUPER+E`  or type `yazi` in terminal.
    On quit, your shell changes to yazi's current directory.

    | Key       | Action                              |
    |-----------|-------------------------------------|
    | `h` / `l` | Parent dir / open                   |
    | `j` / `k` | Down / up                           |
    | `ENTER`   | Open with default app               |
    | `~`       | Go home                             |
    | `-`       | Go to previous dir                  |
    | `gg` / `G`| Top / bottom                        |
    | `/`       | Search by name                      |
    | `Space`   | Toggle select                       |
    | `y`       | Yank (copy)                         |
    | `x`       | Cut                                 |
    | `p`       | Paste                               |
    | `d`       | Move to trash                       |
    | `r`       | Rename                              |
    | `a`       | Create file/dir (end with `/` = dir)|
    | `Tab`     | Toggle preview panel                |
    | `q`       | Quit                                |

    ---

    ## PHASE 7 — HELIX (text editor)

    Helix is **selection-first**: you select something, then act on it.
    This is the opposite of vim (action, then motion).
    Normal mode is the default. `i` enters insert. `ESC` returns to normal.

    ### Modes
    | Key     | Mode                               |
    |---------|------------------------------------|
    | `ESC`   | Back to normal mode                |
    | `i`     | Insert before selection            |
    | `a`     | Insert after selection             |
    | `v`     | Select mode (extend selection)     |
    | `:`     | Command mode                       |

    ### Save and quit
    | Key / Command | Action                     |
    |---------------|----------------------------|
    | `:w`          | Save                       |
    | `:q`          | Quit                       |
    | `:wq`         | Save and quit              |
    | `:q!`         | Quit without saving        |
    | `CTRL+s`      | Save (shortcut)            |

    ### Movement (normal mode)
    | Key           | Action                          |
    |---------------|---------------------------------|
    | `h/j/k/l`     | Character left/down/up/right    |
    | `w/b`         | Next/prev word start            |
    | `e`           | Next word end                   |
    | `gg` / `ge`   | File start / file end           |
    | `gh` / `gl`   | Line start / line end           |
    | `CTRL+d/u`    | Half-page down/up               |
    | `CTRL+f/b`    | Page down/up                    |
    | `/{pattern}`  | Search forward (`n`/`N` repeat) |

    ### Selection (this is the "select first" part)
    | Key    | Action                                  |
    |--------|-----------------------------------------|
    | `x`    | Select current line                     |
    | `vv`   | Select whole line (visual)              |
    | `%`    | Select entire file                      |
    | `mi`   | Select inside a pair `m` then `i`       |
    | `ma`   | Select around a pair (includes delims)  |

    ### Editing
    | Key    | Action                                   |
    |--------|------------------------------------------|
    | `d`    | Delete selection                         |
    | `c`    | Change (delete selection + enter insert) |
    | `y`    | Yank (copy) selection                    |
    | `p`    | Paste after                              |
    | `P`    | Paste before                             |
    | `u`    | Undo                                     |
    | `U`    | Redo                                     |
    | `o`    | Open new line below (enters insert)      |
    | `O`    | Open new line above (enters insert)      |
    | `>/<`  | Indent / unindent selection              |
    | `~`    | Toggle case                              |

    ### Space menu (file, LSP, search)
    | Key          | Action                         |
    |--------------|--------------------------------|
    | `Space+f`    | File picker                    |
    | `Space+b`    | Buffer picker                  |
    | `Space+/`    | Global search (grep)           |
    | `Space+s`    | Symbol picker (LSP)            |
    | `Space+d`    | Diagnostics                    |
    | `Space+k`    | Hover docs (LSP)               |
    | `Space+r`    | Rename symbol (LSP)            |
    | `Space+a`    | Code actions (LSP)             |
    | `Space+Space`| Last picker                    |

    ### LSP navigation
    | Key           | Action                    |
    |---------------|---------------------------|
    | `gd`          | Go to definition          |
    | `gr`          | Go to references          |
    | `gi`          | Go to implementation      |
    | `gt`          | Go to type definition     |
    | `g,`          | Go to last modification   |
    | `CTRL+space`  | Trigger completion        |
    | `[d` / `]d`   | Prev / next diagnostic    |

    ### Multiple selections (Helix superpower)
    | Key     | Action                                       |
    |---------|----------------------------------------------|
    | `C`     | Copy selection to line below (multicursor)   |
    | `s`     | Select regex within selection                |
    | `S`     | Split selection on regex                     |
    | `,`     | Collapse to single cursor                    |
    | `Alt+,` | Remove primary cursor                        |

    ### Windows / buffers
    | Key          | Action                         |
    |--------------|--------------------------------|
    | `CTRL+w+v`   | Split vertical                 |
    | `CTRL+w+s`   | Split horizontal               |
    | `CTRL+w+h/j/k/l` | Navigate splits            |
    | `CTRL+w+q`   | Close split                    |
    | `:bn` / `:bp`| Next / prev buffer             |
    | `:bd`        | Close buffer                   |

    ---

    ## PHASE 8 — MODERN UTILS

    Drop-in replacements for classic Unix tools — same concepts, better output.

    | Classic  | Modern    | Command  | Notes                              |
    |----------|-----------|----------|------------------------------------|
    | `ls`     | eza       | `ls`     | Aliased. Git status, icons, colors |
    | `ls -la` | eza       | `ll`     | Long format with git column        |
    | `cat`    | bat       | `cat`    | Aliased. Syntax highlighting       |
    | `grep`   | ripgrep   | `rg`     | Faster, respects .gitignore        |
    | `find`   | fd        | `fd`     | Simpler syntax                     |
    | `cd`     | zoxide    | `z`      | Frecency-ranked jump               |
    | `du`     | dust      | `du`     | Aliased. Visual tree               |
    | `df`     | duf       | `df`     | Aliased. Grouped, readable         |
    | `ps`     | procs     | `ps`     | Aliased. Color, tree view          |
    | `top`    | bottom    | `top`    | Aliased (`btm` also works)         |
    | `sed`    | sd        | `sd`     | `sd 'old' 'new' file`             |
    | `diff`   | difftastic| `diff`   | Aliased. Syntax-aware              |
    | `curl`   | xh        | `xh`     | `xh GET api.example.com`          |
    | `man`    | tealdeer  | `tldr`   | Practical examples                 |

    ### Not aliased (new tools, no old equivalent)
    | Command     | What it does                              |
    |-------------|-------------------------------------------|
    | `z <dir>`   | Smart jump (learns your habits)           |
    | `zi`        | Interactive zoxide jump (fzf)             |
    | `yq`        | jq but for YAML, TOML, XML too            |
    | `tokei`     | Count lines of code by language           |
    | `ouch`      | `ouch decompress file.tar.gz`             |
    | `watchexec` | `watchexec -e go -- go test ./...`        |
    | `hyperfine` | Benchmark commands                        |
    | `hexyl`     | Hex dump with colors                      |
    | `choose`    | `cut` alternative: `choose 0 2` = cols    |
    | `litecli`   | Better SQLite REPL                        |

    ### fzf key bindings (active everywhere in fish)
    | Key       | Action                              |
    |-----------|-------------------------------------|
    | `Ctrl+R`  | Fuzzy search command history        |
    | `Ctrl+T`  | Fuzzy insert file path              |
    | `Alt+C`   | Fuzzy cd into directory             |

    ---

    ## PHASE 9 — NIXOS

    ### Apply changes
    | Command                              | Action                           |
    |--------------------------------------|----------------------------------|
    | `nrs`                                | Rebuild + switch (apply now)     |
    | `sudo nixos-rebuild switch --upgrade`| Also pull new package versions   |
    | `sudo nixos-rebuild boot`            | Apply on next boot only          |
    | `sudo nixos-rebuild dry-run`         | Preview without applying         |
    | `sudo nixos-rebuild switch --rollback` | Revert to previous generation  |

    ### Packages
    | Command                     | Action                  |
    |-----------------------------|-------------------------|
    | `nix search nixpkgs <name>` | Search for a package    |

    ### Housekeeping
    | Command                          | Action                             |
    |----------------------------------|------------------------------------|
    | `sudo nix-collect-garbage -d`    | Remove old generations + store     |
    | `sudo nix-store --optimise`      | Deduplicate store (slow, optional) |

    ### Config files
    | File                                  | Purpose                                |
    |---------------------------------------|----------------------------------------|
    | `/etc/nixos/configuration.nix`        | System: packages, services, users      |
    | `/etc/nixos/home.nix`                 | Home Manager root + cheatsheet         |
    | `/etc/nixos/modules/hyprland.nix`     | Hyprland keybinds, waybar, mako        |
    | `/etc/nixos/modules/terminal.nix`     | Ghostty, tmux, fish, modern utils      |
    | `/etc/nixos/modules/dev.nix`          | Helix, Go, Python/uv, SQLite, LSPs     |
    | `/etc/nixos/modules/theming.nix`      | GTK/Qt dark theme, dconf               |

    ### NixOS aliases
    | Alias   | Expands to                                     |
    |---------|------------------------------------------------|
    | `ne`    | `sudoedit /etc/nixos/configuration.nix`        |
    | `nhm`   | `sudoedit /etc/nixos/home.nix`                 |

    **Workflow:** edit a `.nix` file → `nrs` → done.

    ---

    ## PHASE 10 — SPOTIFY-PLAYER

    Launch: `SUPER+M`  or type `spotify_player` in terminal.
    Requires Spotify Premium. Config: `~/.config/spotify-player/app.toml`.

    ### Playback
    | Key          | Action                          |
    |--------------|---------------------------------|
    | `Space`      | Play / pause                    |
    | `n` / `p`    | Next / previous track           |
    | `>` / `<`    | Seek forward / backward         |
    | `C-r`        | Cycle repeat mode               |
    | `C-s`        | Toggle shuffle                  |
    | `+` / `-`    | Volume up / down                |
    | `_`          | Mute                            |
    | `^`          | Seek to start of track          |

    ### Navigation
    | Key              | Action                          |
    |------------------|---------------------------------|
    | `j` / `k`        | Down / up                       |
    | `g g` / `G`      | Top / bottom of list            |
    | `C-f` / `C-b`    | Page down / up                  |
    | `Enter`          | Play selected                   |

    ### Actions
    | Key          | Action                                   |
    |--------------|------------------------------------------|
    | `a`          | Actions on current track (like, queue…)  |
    | `A`          | Actions on current playlist / album      |
    | `g a`        | Actions on selected item                 |
    | `r`          | Refresh playback                         |
    | `q`          | Quit                                     |
    | `?`          | Show all keybindings                     |

    ---

    ## PHASE 11 — YUBIKEY  (when hardware arrives)

    ### FIDO2 SSH key (hardware-backed, key never leaves the device)
    ```
    ssh-keygen -t ed25519-sk -O resident
    ```
    - `resident` = key retrievable from YubiKey on any machine
    - Replace the software key on GitHub and Pi NAS
    - Touch the YubiKey on every SSH operation

    ### Web passkeys
    - GitHub → Settings → Password and authentication → Passkeys
    - Google → Security → 2-Step Verification → Passkeys

    ### Test SSH
    ```
    ssh -T git@github.com
    ```
  '';

  # Additional user packages not covered by specific program modules
  home.packages = with pkgs; [
    # Clipboard
    wl-clipboard

    # System utilities
    ripgrep
    fd
    jq
    htop
    unzip

    # Wayland utilities
    wlr-randr

    # Spotify TUI client
    spotify-player
  ];
}
