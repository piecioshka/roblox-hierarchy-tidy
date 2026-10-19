# Hierarchy Tidy 🧹

<!-- prettier-ignore-start -->

[![github-ci](https://github.com/piecioshka/roblox-hierarchy-tidy/actions/workflows/ci.yml/badge.svg)](https://github.com/piecioshka/roblox-hierarchy-tidy/actions/workflows/ci.yml)
[![deploy](https://github.com/piecioshka/roblox-hierarchy-tidy/actions/workflows/deploy.yml/badge.svg)](https://github.com/piecioshka/roblox-hierarchy-tidy/actions/workflows/deploy.yml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://piecioshka.mit-license.org)
![luau](https://img.shields.io/badge/built%20with-Luau-00A2FF.svg)
![typescript](https://img.shields.io/badge/landing%20page-TypeScript-3178c6.svg)
![roblox-studio](https://img.shields.io/badge/Roblox%20Studio-plugin-555.svg)

<!-- prettier-ignore-end -->

> Give a ⭐️ if this project helped you!

A Roblox Studio plugin with a dockable panel for tidying up the Explorer hierarchy: bulk selection, grouping, name numbering and removing empty containers. Every operation goes through `ChangeHistoryService`, so a plain `Ctrl+Z` undoes it.

The plugin lives in [`roblox/hierarchy-tidy`](roblox/hierarchy-tidy) and is written in Luau (`--!strict`). The repository root additionally holds a Next.js landing page — the plugin does not need it to run.

## Features

- 🔍 **Find and select** — filter by name fragment and by class (`BasePart`, `Script`, …) across `Workspace`, the current selection, `ServerScriptService` or `StarterGui`. A separate button selects siblings with colliding names. Capped at 500 hits per query.
- 📦 **Grouping** — the selection into a new `Folder` or `Model` (objects nested inside other selected ones are skipped), splitting by class into `Parts` / `Scripts` / …, and unpacking a container (children move up, the empty container is removed).
- 🏷️ **Renaming** — bulk numbering by pattern, where `{n}` is the number and `{class}` the class name. Configurable start index, padding (`001`) and order (alphabetical or as selected).
- 🧽 **Tidy up** — recursive removal of empty `Folder` / `Model` / `Configuration` (from the leaves up), scoped to the selection or the whole `Workspace`, plus alphabetical `LayoutOrder` sorting of `GuiObject` children.
- 💾 **Sticky settings** — field values and scopes are stored via `plugin:SetSetting`, so they survive a Studio restart. The panel follows the light/dark Studio theme.

## Installation

The plugin ships as source, so you build it yourself. You need [Rojo](https://rojo.space) — install it with `cargo install rojo` or `aftman add rojo-rbx/rojo`.

### Windows

```powershell
cd roblox\hierarchy-tidy
rojo build -o HierarchyTidy.rbxmx
Copy-Item HierarchyTidy.rbxmx "$env:LOCALAPPDATA\Roblox\Plugins"
```

The plugins folder is `%LOCALAPPDATA%\Roblox\Plugins`. If it does not exist yet, open Studio and use **Plugins → Plugins Folder** to create and reveal it.

### macOS

```bash
cd roblox/hierarchy-tidy
rojo build -o HierarchyTidy.rbxmx
cp HierarchyTidy.rbxmx ~/Documents/Roblox/Plugins/
```

The plugins folder is `~/Documents/Roblox/Plugins`. Same trick as above if it is missing: **Plugins → Plugins Folder** in Studio.

On both systems, restart Studio after copying the file. A **Hierarchy Tidy** toolbar shows up with a button that toggles the panel.

### Without Rojo

1. In Studio, create a `Script` in `ServerStorage` and paste in the contents of `src/init.server.luau`.
2. Recreate the module tree as `ModuleScript` children of that script: `Theme`, `Widget`, `UiKit`, `Settings`, `History`, plus an `Actions` folder holding `Group`, `Rename`, `Cleanup` and `Find`.
3. Right-click the script and pick **Save as Local Plugin**.

This works, but you repeat the whole dance on every change — for longer sessions use the live sync with `rojo serve` described in [CONTRIBUTING.md](CONTRIBUTING.md).

## Keyboard shortcuts

Three actions register under `File → Advanced → Customize Shortcuts` (unbound by default):

- `Hierarchy Tidy: group into Folder`
- `Hierarchy Tidy: unpack container`
- `Hierarchy Tidy: remove empty containers`

They act on the current Explorer selection and log the result to the Output window.

## Contributing

Building the plugin, live sync with Rojo, the module map and the landing page: see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[The MIT License](https://piecioshka.mit-license.org) @ 2026
