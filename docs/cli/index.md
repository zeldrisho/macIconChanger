---
title: CLI Installation
section: cli
order: 1
---


IconChanger includes a command-line interface for scripting and automation.

## Install from the App

1. Open IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool**, click **Install**.

The command is installed in `~/.local/bin` and does not require administrator privileges. It is available as `iconchanger` if `~/.local/bin` is on your `PATH`.

If it is not on your `PATH`, add this to your shell configuration file (for example, `~/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new terminal window or restart your terminal.

## Install Manually

If you prefer to install manually (e.g., in a dotfiles script):

```bash
mkdir -p ~/.local/bin
cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI ~/.local/bin/iconchanger
chmod +x ~/.local/bin/iconchanger
export PATH="$HOME/.local/bin:$PATH"
```

## Verify Installation

```bash
iconchanger --version
```

## Uninstall

From the app: **Settings** > **Advanced** > **Uninstall**.

Or manually:

```bash
rm ~/.local/bin/iconchanger
```

## Next Steps

See the [Command Reference](./commands) for all available commands.
