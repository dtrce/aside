# aside

**Sidecar files for your git repos — without touching the repo.**

`aside` (aliased as `asd`) lets you keep notes, scratch files, and personal artifacts associated with a git repo, stored in a central location outside the repo tree. No `.gitignore` entries, no dotfiles, no mess.

## How it works

Every git repo has a remote origin URL. `aside` uses that URL to create a dedicated directory in `~/.local/share/aside/` where your sidecar files live. Any command you pass to `asd` gets its filename arguments rewritten to full paths inside that directory, then executed.

```
~/projects/myapp $ asd vi notes.md       # opens ~/.local/share/aside/github.com/acme/myapp/notes.md
~/projects/myapp $ asd cat notes.md      # prints it
~/projects/myapp $ asd ls                # lists your sidecar files
~/projects/myapp $ asd code scratch.js   # open in VS Code
```

The repo stays completely clean. Your notes follow the repo, not the clone.

## Install

```bash
# Copy the script somewhere on your PATH and create the alias
cp aside ~/.local/bin/aside
chmod +x ~/.local/bin/aside
ln -s aside ~/.local/bin/asd
```

## Usage

### Built-in commands

These commands are handled directly by `aside` and are never proxied to an external command:

```bash
asd add <name> ...    # Create sidecar file(s)
asd rm <name> ...     # Delete sidecar file(s)
asd ls                # List sidecar files for current repo
asd count             # Count sidecar files for current repo
asd where             # Print store path for current repo
asd help              # Show built-in help
```

### Proxied commands

Anything that isn't one of the built-ins above is treated as an external command. `asd` rewrites the filename arguments to their full sidecar paths and `exec`s the command. If the file doesn't exist yet, it's auto-created.

```bash
# Edit files
asd vi notes.md
asd nano todo.md
asd code scratch.js

# Read files
asd cat notes.md
asd bat notes.md

# Write or inspect files with tools that operate directly on the aside path
asd cat notes.md
asd code scratch.js
```

### How the repo is identified

`aside` reads the remote origin URL from `git remote get-url origin` and derives a stable directory path from it. This means:

- Multiple clones of the same repo share the same sidecar files
- Forks with different remotes get their own space
- No sidecar files are created inside the repo itself

## Storage

```
~/.local/share/aside/
├── github.com/
│   └── your-org/
│       ├── webapp/
│       │   ├── notes.md
│       │   ├── todo.md
│       │   └── scratch.sh
│       └── api-server/
│           ├── notes.md
│           └── queries.sql
└── ...
```

## Ideas

Some ways people use sidecar files:

- `notes.md` — running log of decisions, context, "why did I do this"
- `todo.md` — personal task list that doesn't belong in the issue tracker
- `scratch.sh` — throwaway test commands
- `env.local` — secrets or local config you don't want anywhere near git
- `queries.sql` — ad-hoc database queries for debugging
- `curl-tests.sh` — API call scratchpad
- `meeting-notes/` — subdirectories work too

## Tips

**Sync across machines:** Since sidecar files are keyed by remote URL, you can sync `~/.local/share/aside/` with Syncthing, rsync, or even make it a git repo itself.

**Shell hooks:** Get a notification whenever you `cd` into a repo that has sidecar files. See [Shell Hooks](#shell-hooks) below.

## Shell Hooks

The `hooks/` directory contains shell scripts that notify you when you `cd` into a git repo that has sidecar files. The hook runs `aside count` on every directory change and prints a short message when files are found.

### Fish

```fish
# Add to ~/.config/fish/config.fish
source /path/to/aside/hooks/hook.fish
```

### Bash

```bash
# Add to ~/.bashrc
source /path/to/aside/hooks/hook.bash
```

### Zsh

```zsh
# Add to ~/.zshrc
source /path/to/aside/hooks/hook.zsh
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `ASIDE_HOME` | `~/.local/share/aside` | Root directory for all sidecar files |

## License

MIT
