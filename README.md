# moon-example-docker-prune-bug

## Reproduce moonrepo/moon#2573

This example reproduces **[moonrepo/moon#2573](https://github.com/moonrepo/moon/issues/2573)**: `moon docker prune` incorrectly drops production dependencies for apps whose `package.json` name matches their folder name (unscoped packages).

### The apps

- `apps/non-scoped-package` — **FAILS** after prune (unscoped name = folder name)
- `apps/non-scoped-package-different-name` — **WORKS** (name ≠ folder name)
- `apps/scoped-package` — **WORKS** (scoped name)
- `apps/non-scoped-package-moon-start` — installs at runtime (workaround with `moon run`)

### The core issue

When an app's `package.json` name is unscoped and matches its folder name, `moon docker prune` incorrectly identifies its dependencies and removes them from the final image. This forces you to choose between:

1. **Direct node startup** (`node main.js`): Image is minimal but fails at runtime (missing dependencies)
2. **Moon-managed startup** (`moon run <app>:start`): App works but installs dependencies at container startup, negating optimization benefits

This is a **moon bug**, not expected behavior. Scoped packages and renamed packages work correctly.

### Logging

Each Dockerfile includes:
- **Post-prune logging** (BUILD stage): Lists `node_modules` after `moon docker prune` to show what dependencies remain
- **Runtime logging** (START stage): Lists `node_modules` at startup to show what's available to the app

### Run the reproduction

Or with `yarn`:

```bash
yarn test:docker:issue-2573
```
