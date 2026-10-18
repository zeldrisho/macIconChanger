---
title: Initial Setup
section: guide
order: 2
---


IconChanger changes icons on apps you own and can write to without administrator privileges. macOS may separately require App Management permission for some targets. IconChanger uses its privileged helper only when an operation cannot be performed as your user.

## Optional privileged setup

The helper in `/Library/PrivilegedHelperTools/IconChanger/` and its scoped sudoers rule are only needed for protected targets or background operations that require elevated access. You can use IconChanger for user-writable apps without installing the helper. Never add a broad `ALL ALL=(ALL) NOPASSWD` rule; use the app's setup flow if you choose to configure the helper.

## Security

IconChanger uses several security measures to protect the helper pipeline:

- **No elevation for writable apps** — User-owned writable apps are changed using the bundled icon utility under your account.
- **Optional privileged helper** — Protected-target operations may require setup and administrator authorization. Keep this disabled unless you need that functionality.
- **Integrity checks** — When the privileged helper is used, installed helper files are checked against the bundled files.
- **Audit logging** — Successful icon changes and restores are appended to
  `~/Library/Application Support/com.zhuhaoyu.IconChanger/audit.log`.
- **Developer diagnostics** — After enabling Developer Mode, open the
  developer-only **Settings → Developer → Diagnostics** tab to independently enable
  `diagnostics.log`. You can choose which icon operations and event types are
  recorded, whether application paths are included, and whether restore entries
  include the selected icon type or its full cache path. Full icon paths are off
  by default.

The diagnostics log uses JSON Lines so each operation step is independently
searchable. It includes operation and batch identifiers for correlating a
restore with helper execution, Dock refreshes, failures, skips, and performance
timings. The file is owner-only (`0600`), rotates at 5 MiB, and retains three
archives. Developer Mode and **Enable Diagnostics Log** must both remain
enabled for diagnostics to be written.

## Manual setup

Do not create a broad passwordless sudoers rule manually. If you need protected-target support, use the app's permission setup flow and review the exact user-scoped rule it manages.

## Verifying Setup

After setup, the app should show the application list in the sidebar. If you see the setup prompt again, the configuration may not have been applied correctly.

You can verify the setup from the menu bar: click the **...** menu and select **Check Setup Status**.

## Limitations

Applications protected by macOS System Integrity Protection (SIP) cannot have their icons changed. This is a macOS restriction and cannot be bypassed.

Common SIP-protected apps include:
- Finder
- Safari (on some macOS versions)
- Other system applications in `/System/Applications/`
