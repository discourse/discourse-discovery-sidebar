# Discovery Sidebar

A theme component that adds a configurable sidebar next to Discourse topic lists, built on the Blocks API. Works with any theme: install it as a component, then restyle it through CSS tokens.

Three blocks, each driven by an `objects` theme setting. Every entry of a setting is one panel; entries scoped to categories replace the default panel on those categories.

- **Space** — on a category page, the top-level category and its subcategories; on global lists, all top-level categories.
- **Leaderboard** — top users from the gamification plugin, per period and leaderboard id.
- **Resources** — a list of links with icons and descriptions.

The component owns the `sidebar-discovery` block outlet. A theme that also calls `api.renderBlocks("sidebar-discovery", …)` must drop that call.

## Styling

All sizes and colours come from tokens on `:root`, derived from core variables. Override them in your theme:

```scss
:root {
  --discovery-sidebar-width: 18rem;
  --discovery-sidebar-gap: var(--space-6);
  --discovery-sidebar-panel-gap: var(--space-4);
  --discovery-sidebar-panel-bg: var(--secondary);
  --discovery-sidebar-panel-border: 1px solid var(--primary-low);
  --discovery-sidebar-panel-radius: var(--d-border-radius-large);
  --discovery-sidebar-panel-padding: var(--space-4);
  --discovery-sidebar-panel-title-size: var(--font-0);
  --discovery-sidebar-panel-text-size: var(--font-down-1);
  --discovery-sidebar-panel-muted: var(--primary-medium);
  --discovery-sidebar-panel-accent: var(--tertiary);
  --discovery-sidebar-row-hover-bg: var(--primary-very-low);
  --discovery-sidebar-mark-size: 1.25rem;
}
```

Themes with a fixed page width can widen it while a panel renders:

```scss
#main-outlet-wrapper:has(.discovery-layout .block-panel) {
  --d-max-width: calc(1000px + var(--discovery-sidebar-width) + var(--discovery-sidebar-gap));
}
```

Hide the category and tag dropdowns in the navbar while a panel renders:

```scss
.discovery-layout:has(.block-panel) .navigation-container .category-breadcrumb {
  display: none;
}
```

## Development

```sh
pnpm install
pnpm lint
```
