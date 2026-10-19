# Contributing to Hierarchy Tidy

How to work on the plugin and on the landing page. For what the plugin does and how to install it, see the [README](README.md).

The repository holds two independent parts:

- `roblox/hierarchy-tidy/` - the Roblox Studio plugin, written in Luau (`--!strict`) and built with [Rojo](https://rojo.space)
- the repository root (`app/`, `components/`, `lib/`) - a Next.js landing page; the plugin does not need it to run

## Plugin

### Prerequisites

[Rojo](https://rojo.space), installed with `cargo install rojo` or `aftman add rojo-rbx/rojo`.

### Build

```bash
cd roblox/hierarchy-tidy
rojo build -o HierarchyTidy.rbxmx
```

Copy the file into the Studio plugins folder as described in the README and restart Studio.

### Live sync while developing

Instead of rebuilding by hand, serve the project and let Studio pull changes:

```bash
cd roblox/hierarchy-tidy
rojo serve
```

Install the [Rojo](https://create.roblox.com/store/asset/13916111004) plugin in Studio and connect to the server. Edits to the `.luau` files land in Studio immediately, no restart needed.

### Plugin structure

```
roblox/hierarchy-tidy/
  default.project.json   Rojo configuration (src → Script "HierarchyTidy")
  src/
    init.server.luau     toolbar, DockWidgetPluginGui, PluginActions
    Widget.luau          panel contents
    UiKit.luau           controls (sections, buttons, inputs, cycle)
    Theme.luau           colors from StudioTheme + reaction to theme changes
    Settings.luau        persistent settings (plugin:Get/SetSetting)
    History.luau         wrapper around ChangeHistoryService:TryBeginRecording
    Actions/
      Group.luau         grouping, splitting by class, flatten
      Rename.luau        bulk name numbering
      Cleanup.luau       empty containers, LayoutOrder, selection summary
      Find.luau          search by name/class, duplicate names
```

`default.project.json` maps `src` onto a `Script` named `HierarchyTidy`, so `init.server.luau` is the entry point and every other file becomes a `ModuleScript` child of it.

Every operation that changes the hierarchy goes through `History.luau` (`ChangeHistoryService`), so a plain `Ctrl+Z` undoes it.

The toolbar icon is empty - drop your own `rbxassetid://…` into `init.server.luau` if you want one.

## Landing page

### Prerequisites

- Node.js from `.nvmrc` (`lts/krypton`)
- pnpm, in the version pinned in the `packageManager` field of `package.json` (for example through Corepack)

```bash
pnpm install
pnpm dev
```

### Scripts

| Command             | What it does                                                 |
| ------------------- | ------------------------------------------------------------ |
| `pnpm dev`          | dev server at `http://localhost:3000`, or the next free port |
| `pnpm build`        | static export into `out/` (includes the TypeScript check)    |
| `pnpm start`        | serves the export locally                                    |
| `pnpm test`         | unit tests (Vitest)                                          |
| `pnpm typecheck`    | `tsc --noEmit`                                               |
| `pnpm lint`         | ESLint                                                       |
| `pnpm format`       | Prettier, writes changes                                     |
| `pnpm format:check` | Prettier, check only                                         |

A husky pre-commit hook runs lint-staged, which formats and lints staged files.

### CI and deployment

- [`ci.yml`](.github/workflows/ci.yml) runs on every push and pull request: `format:check`, `lint`, `test` and `build`.
- [`deploy.yml`](.github/workflows/deploy.yml) deploys the static export to GitHub Pages on every push to `main`. It needs Pages set to **GitHub Actions** in the repository settings, which requires a public repository on the free plan.

Pages serves the site from `/<repo>`, so the workflow builds with `NEXT_PUBLIC_BASE_PATH=/roblox-hierarchy-tidy`. Leave that variable unset locally.

## Conventions

Commits follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `docs:`, `chore:`, `build(deps):`).
