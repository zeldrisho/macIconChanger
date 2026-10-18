---
title: CLI Installation
section: cli
order: 1
---


IconChanger includes a command-line interface for scripting and automation.

## Install from the App

1. Open IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool**, click **Install**.

The command is installed in `~/.local/bin` and does not require administrator privileges.

The `iconchanger` command is now available in your terminal.

## Install Manually

If you prefer to install manually (e.g., in a dotfiles script):

```bash
mkdir -p ~/.local/bin
cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI ~/.local/bin/iconchanger
chmod +x ~/.local/bin/iconchanger
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
