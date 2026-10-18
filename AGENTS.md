# Agent Instructions

## Toolchain

- Use **Xcode and Swift Package Manager** via `IconChanger.xcodeproj`; there is no standalone `Package.swift`.
- Keep compatibility with macOS 13.0 and Swift 5 language mode.
- Run commands below from the repository root; regression scripts require Bash, Swift, and Python 3 on macOS.

## Commands

| Task                        | Command                                                                                                                                                             |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Resolve dependencies        | `xcodebuild -resolvePackageDependencies -project IconChanger.xcodeproj -scheme IconChanger`                                                                            |
| Focused regression (example) | `bash tests/icon-appearance.sh`                                                                                                                                      |
| Helper security regressions | `bash tests/security-helper.sh && bash tests/security-fileicon.sh`                                                                                                    |
| All regression tests        | `bash tests/run.sh`                                                                                                                                                  |
| Unsigned CI build           | `xcodebuild build -project IconChanger.xcodeproj -scheme IconChanger -configuration Release -destination 'generic/platform=macOS' CODE_SIGNING_ALLOWED=NO -quiet`        |

## Key Conventions

- Use `fd` for file discovery and `rg` for searching file contents.
- Run the relevant `tests/*.sh` wrapper rather than compiling its Swift test file directly; wrappers select the required source files.
- Register new regression scripts in `tests/run.sh`.
- Keep independently testable policy logic in `IconChanger/Services/*Policy.swift`, separate from SwiftUI and system side effects.
- Add new GUI source files to `IconChanger.xcodeproj/project.pbxproj` where groups use explicit file references; `IconChanger/CLI/`, `IconChanger/Config/`, and `IconChangerCLI/` use synchronized groups.
- Keep storage paths and migrations in `IconChanger/Utilities/AppPaths.swift` aligned with their standalone implementation in `IconChangerCLI/IconChangerCLI.swift`.
- Preserve the privileged helper's path validation and scoped sudo access when changing `IconChanger/Resources/helper.sh`, `IconChanger/Resources/fileicon`, or permission setup.
- Do not reintroduce irreversible Launchpad database deletion; `tests/no-launchpad-mutation.sh` guards against it.
- Use `IconChanger/Resources/Localizable.xcstrings` for user-facing localization.

## External References

| Need                                    | File                                      |
| --------------------------------------- | ----------------------------------------- |
| Project overview and contribution setup  | `README.md`                               |
| Helper setup and security model         | `docs/setup.md`                           |
| CLI behavior and commands               | `docs/cli/commands.md`                    |
| Configuration import/export             | `docs/import-export.md`                   |
| CI build and regression checks          | `.github/workflows/build.yml`             |
| Release candidate build and signing     | `.github/workflows/release-candidate.yml` |
| Release publication                     | `.github/workflows/publish-release.yml`   |
| Documentation deployment                | `.github/workflows/docs.yml`              |
