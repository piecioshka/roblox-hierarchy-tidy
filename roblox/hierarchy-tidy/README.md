# Hierarchy Tidy — plugin source

Luau source of the Roblox Studio plugin. Features, installation and the module map live in the [repository README](../../README.md); this file only covers building from this directory.

Build a plugin file with [Rojo](https://rojo.space):

```bash
rojo build -o HierarchyTidy.rbxmx
```

Serve it to Studio instead, with live sync:

```bash
rojo serve
```

`default.project.json` maps `src` onto a `Script` named `HierarchyTidy`, so `init.server.luau` is the entry point and every other file becomes a `ModuleScript` child of it.
