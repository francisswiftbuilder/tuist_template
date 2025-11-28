# Tuist iOS Template

Minimal Tuist template for a modular iOS app.

## Requirements

- Xcode with iOS 15 simulator
- Swift 6 toolchain
- [Tuist](https://tuist.dev) — version pinned in `.mise.toml`

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
make format    # apply swift-format to hand-written sources
make lint      # verify formatting (used by CI)
make clean     # tuist clean + remove *.xcodeproj/*.xcworkspace
```

`format` and `lint` skip files carrying a `DO NOT EDIT` header, so generated
helpers are never reformatted against their emitters.

## Architecture

- `App` project holds the `.app` target plus any AppExtension targets.
- Feature/Domain/Data/Core/Shared are separate projects under `Projects/<Layer>/<Module>`.
- App depends on modules only via `Dependencies.appDependencies` (project dependencies).

## Schemes

`make sync` derives schemes from the target list:

- `App` — the application.
- `Example<Module>` — a runnable demo app for a Feature module scaffolded with an Example.
- `<Layer><Module>Tests` — runs that module's tests alone, with coverage enabled.

Dependencies for a new module's Sources / Interface / Testing / Tests targets are
declared by hand in `Tuist/ProjectDescriptionHelpers/Dependencies.swift`; `make sync`
does not infer them.

After `make generate`, open the workspace and run:

```bash
open App.xcworkspace
```

The workspace and the app project are named after `environment.name`
(`Tuist/ProjectDescriptionHelpers/Environment.swift`), which defaults to `App`.

Run the `App` scheme to see the SwiftUI “Hello, World!” screen.

## License

MIT. See [LICENSE](LICENSE).
