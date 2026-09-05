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
  --tc-discoverySidebar-width: 18rem;
  --tc-discoverySidebar-gap: var(--space-6);
  --tc-discoverySidebar-panel-gap: var(--space-4);
  --tc-discoverySidebar-panel-bg: var(--secondary);
  --tc-discoverySidebar-panel-border: 1px solid var(--primary-low);
  --tc-discoverySidebar-panel-radius: var(--d-border-radius-large);
  --tc-discoverySidebar-panel-padding: var(--space-4);
  --tc-discoverySidebar-panel-title-size: 1rem;
  --tc-discoverySidebar-panel-meta-size: 0.875rem;
  --tc-discoverySidebar-panel-muted: var(--primary-medium);
  --tc-discoverySidebar-panel-accent: var(--tertiary);
  --tc-discoverySidebar-row-hover-bg: var(--primary-very-low);
  --tc-discoverySidebar-mark-size: 1.25rem;
}
```

Themes with a fixed page width can widen it while a panel renders:

```scss
#main-outlet-wrapper:has(.discovery-layout .block-panel) {
  --d-max-width: calc(1000px + var(--tc-discoverySidebar-width) + var(--tc-discoverySidebar-gap));
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
