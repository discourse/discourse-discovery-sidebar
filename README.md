# Discovery Sidebar

A theme component that adds a configurable sidebar next to Discourse topic lists, built on the Blocks API. Works with any theme: install it as a component, then restyle it through CSS tokens.

Five blocks. Display choices are args in the layout file: panel titles and icons, whether a panel stays on small screens, the space block's description and topic counts, the number of events and topics, the leaderboard's user count and period. Settings hold only what differs per site: where a panel appears, which category feeds it, which leaderboard a category shows, and which links a resource panel lists.

- **Space** — on a category page, the top-level category and its subcategories; on global lists, all top-level categories. The `spaces` setting decides where it appears.
- **Events** — upcoming post events from the `events` setting: the events category of the matching entry, else the whole site. Falls back to the most recent past events, and hides itself when there are none at all. Needs the Events plugin; the panel disappears without it.
- **Topics** — a compact topic list of the current space, or of the whole site on global lists. The `topic_lists` setting picks the list (latest, hot or top), the period for top, and optionally a tag. Pinned topics are left out.
- **Leaderboard** — the gamification leaderboard from the `leaderboards` setting: the entry scoped to the current category, else the unscoped default. The panel takes its title and period from the leaderboard itself unless the layout passes a `title` or `period` arg.
- **Resources** — the links from the `resources` setting: the entry scoped to the current category, else the unscoped default.

The component owns the `sidebar-discovery` block outlet. A theme that also calls `api.renderBlocks("sidebar-discovery", …)` must drop that call.

## Settings

Every panel is driven by one setting with one entry per place it appears. Remove all entries of a setting to turn that panel off.

- **Sidebar position** — `aside` (default) puts the sidebar next to the navbar and the list, full height. `below-navbar` keeps the navbar full width and starts the sidebar next to the list.
- **Spaces** — one entry per place the space panel appears. Scope an entry to categories, or leave categories empty to show it everywhere. Remove the unscoped entry to show the panel only on the scoped categories. Each entry picks where the "All spaces" link goes: the home page, latest, or categories.
- **Events** — one entry per place the events panel appears. Scope an entry to categories, or leave categories empty for the fallback. Pick an events category, or leave it empty to show the events of the whole site.
- **Topic lists** — one entry per place the topics panel appears. Scope an entry to categories, or leave categories empty for the fallback. Pick the list, the period for top, and optionally a tag to narrow the list.
- **Leaderboards** — one entry per leaderboard to show. Scope an entry to categories, or leave categories empty for the fallback. No ID means the plugin's default leaderboard. The panel disappears when the leaderboard is missing or inaccessible, so the setting is harmless without the Gamification plugin. Temporary failures show a retry button.
- **Resources** — one entry per set of links. Scope an entry to categories, or leave categories empty for the fallback.

## Styling

All sizes and colours come from tokens on `:root`, derived from core variables. Override them in your theme:

```scss
:root {
  --tc-DiscoverySidebar-size-inline: 18rem;
  --tc-DiscoverySidebar-space-gap-inline: var(--space-6);
  --tc-DiscoverySidebar-space-gap-block: var(--space-4);
  --tc-DiscoverySidebar-BlockPanel-color-background: var(--secondary);
  --tc-DiscoverySidebar-BlockPanel-border-width: 1px;
  --tc-DiscoverySidebar-BlockPanel-color-border: var(--primary-low);
  --tc-DiscoverySidebar-BlockPanel-border-radius: var(--d-border-radius-large);
  --tc-DiscoverySidebar-BlockPanel-space-padding: var(--space-4);
  --tc-DiscoverySidebar-BlockPanel-title-font-size: 1rem;
  --tc-DiscoverySidebar-BlockPanel-font-size: 0.875rem;
  --tc-DiscoverySidebar-BlockPanel-color-text-muted: var(--primary-medium);
  --tc-DiscoverySidebar-BlockPanel-color-icon-muted: var(--primary-medium);
  --tc-DiscoverySidebar-BlockPanel-color-text-accent: var(--tertiary);
  --tc-DiscoverySidebar-BlockPanel-row-color-background-hovered: var(
    --primary-very-low
  );
  --tc-DiscoverySidebar-CategoryMark-size-icon: 1.25rem;
}
```

Themes with a fixed page width can widen it while a panel renders:

```scss
#main-outlet-wrapper:has(.discovery-layout .block-panel) {
  --d-max-width: calc(
    1000px + var(--tc-DiscoverySidebar-size-inline) +
      var(--tc-DiscoverySidebar-space-gap-inline)
  );
}
```

Hide the category and tag dropdowns in the navbar while a panel renders:

```scss
.discovery-layout:has(.block-panel) .navigation-container .category-breadcrumb {
  display: none;
}
```
