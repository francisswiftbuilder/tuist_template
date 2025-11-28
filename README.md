# Tuist iOS Template

Minimal Tuist template for a modular iOS app.

## Requirements

- Xcode with iOS 15 simulator
- Swift 6 toolchain
- [Tuist](https://tuist.dev)

## Structure

- `Projects/App` – main SwiftUI app (`Hello, World!`)
- `Projects/<Layer>/<Module>` – Feature / Domain / Data / Core / Shared modules
- `Tuist/ProjectDescriptionHelpers` – Tuist helpers & generated files
- `Tuist/Plugins` – local Tuist plugins (configuration, targets, templates, environment)
- `Tuist/Scripts` – Swift scripts for module/target/scheme generation

## Commands

```bash
make generate  # install tuist deps, sync, generate workspace
make module    # interactive module scaffold + sync
make sync      # rescan modules & regenerate Tuist helpers
make clean     # tuist clean + remove *.xcodeproj/*.xcworkspace
```

## Architecture

- `App` project has only the `.app` target.
- Feature/Domain/Data/Core/Shared are separate projects under `Projects/<Layer>/<Module>`.
- App depends on modules only via `Dependencies.appDependencies` (project dependencies).

After `make generate`, open the workspace and run:

```bash
open App.xcworkspace
```

Run the `App` scheme to see the SwiftUI “Hello, World!” screen.

