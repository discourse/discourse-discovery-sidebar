# Discovery Sidebar

Adds a sidebar of panels next to Discourse topic lists, built on the Blocks API. Works with any theme.

## Panels

| Panel       | What it shows                                                              | Setting        |
| ----------- | -------------------------------------------------------------------------- | -------------- |
| Space       | The current category and its subcategories, with a link to all categories. | `spaces`       |
| Events      | Upcoming events in the category, or recent ones.                           | `events`       |
| Topics      | A short list of topics, from the whole site or the category.               | `topic_lists`  |
| Leaderboard | Top contributors, across the site or in the category.                      | `leaderboards` |
| Resources   | Helpful links, shared or specific to the category.                         | `resources`    |

## Settings

Each panel setting holds one entry per place the panel appears. An entry scoped to categories replaces the unscoped entry there; an unscoped entry is the fallback everywhere else. Remove all entries to turn a panel off.

`sidebar_position` is `aside` (full height, next to the navbar and list) or `below-navbar` (next to the list only).

## Conditions

The panels render only:

- on topic lists, not on `/categories`
- on larger screens
- when their data exists: Events needs the Events plugin, Leaderboard the Gamification plugin

The component owns the `sidebar-discovery` block outlet, so no other theme or component can render blocks there.

## Styling

Override these properties on `:root`:

```css
:root {
  /* Layout */
  --tc-DiscoverySidebar-size-inline: 18rem;
  --tc-DiscoverySidebar-space-gap-inline: var(--space-6);
  --tc-DiscoverySidebar-space-gap-block: var(--space-4);

  /* Panel colors */
  --tc-DiscoverySidebar-BlockPanel-color-background: var(--secondary);
  --tc-DiscoverySidebar-BlockPanel-color-border: var(--primary-low);
  --tc-DiscoverySidebar-BlockPanel-color-text-default: var(--primary);
  --tc-DiscoverySidebar-BlockPanel-color-text-muted: var(--primary-medium);
  --tc-DiscoverySidebar-BlockPanel-color-icon-muted: var(--primary-medium);
  --tc-DiscoverySidebar-BlockPanel-color-text-accent: var(--tertiary);
  --tc-DiscoverySidebar-BlockPanel-row-color-background-hovered: var(
    --primary-very-low
  );

  /* Panel typography */
  --tc-DiscoverySidebar-BlockPanel-title-font-size: 1rem;
  --tc-DiscoverySidebar-BlockPanel-font-size: 0.875rem;

  /* Panel shape and spacing */
  --tc-DiscoverySidebar-BlockPanel-border-width: 1px;
  --tc-DiscoverySidebar-BlockPanel-border-radius: var(--d-border-radius-large);
  --tc-DiscoverySidebar-BlockPanel-space-padding: var(--space-4);

  /* Category icons */
  --tc-DiscoverySidebar-CategoryMark-size-icon: 1.25rem;
}
```
