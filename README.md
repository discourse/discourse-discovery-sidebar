# Discovery Sidebar

A theme component that adds a configurable sidebar next to Discourse topic lists, built on the Blocks API. Works with any theme: install it as a component, then restyle it through CSS tokens.

Three blocks. Display choices are args in the layout file: panel titles and icons, whether a panel stays on small screens, the space block's description and topic counts, the leaderboard's user count and period. Settings hold only what differs per site: where the space panel appears, which leaderboard a category shows, and which links a resource panel lists.

- **Space** — on a category page, the top-level category and its subcategories; on global lists, all top-level categories. The `spaces` setting decides where it appears.
- **Leaderboard** — the gamification leaderboard from the `leaderboards` setting: the entry scoped to the current category, else the unscoped default.
- **Resources** — the links from the `resources` setting: the entry scoped to the current category, else the unscoped default.

The component owns the `sidebar-discovery` block outlet. A theme that also calls `api.renderBlocks("sidebar-discovery", …)` must drop that call.

## Settings

- **Sidebar position** — `aside` (default) puts the sidebar next to the navbar and the list, full height. `below-navbar` keeps the navbar full width and starts the sidebar next to the list.
- **Spaces** — one entry per place the space panel appears. Scope an entry to categories, or leave categories empty to show it everywhere. Remove the unscoped entry to show the panel only on the scoped categories.
- **Leaderboards** — one entry per leaderboard to show. Scope an entry to categories, or leave categories empty for the fallback. No ID means the plugin's default leaderboard. The panel disappears when the leaderboard is missing or inaccessible, so the setting is harmless without the Gamification plugin. Temporary failures show a retry button.
- **Resources** — one entry per set of links, named for the settings list. Scope an entry to categories, or leave categories empty for the fallback.

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
  --d-max-width: calc(
    1000px + var(--tc-discoverySidebar-width) + var(--tc-discoverySidebar-gap)
  );
}
```

Hide the category and tag dropdowns in the navbar while a panel renders:

```scss
.discovery-layout:has(.block-panel) .navigation-container .category-breadcrumb {
  display: none;
}
```
