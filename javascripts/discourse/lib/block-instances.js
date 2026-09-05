// The one place scoping logic lives. An instance is an entry of a block's
// objects setting. It applies when its placement matches the outlet the block
// was rendered into and its category scope matches the page:
//
//   - a scoped entry (categories set) matches when the current category or
//     its parent is listed; every matching scoped entry renders
//   - an unscoped entry (no categories) is the fallback: it renders only when
//     no scoped entry of the same block matches the page
//
// So one default panel covers the whole site, and adding a panel for a space
// replaces the default there instead of stacking on top of it.

export function rootCategory(category) {
  return category?.parentCategory ?? category ?? null;
}

function placementMatches(entry, placement) {
  // a fresh entry has no placement yet; treat it as the default sidebar
  return (entry.placement ?? "discovery-sidebar") === placement;
}

function scopeMatches(entry, category) {
  if (!category) {
    return false;
  }
  return (
    entry.categories.includes(category.id) ||
    entry.categories.includes(category.parent_category_id)
  );
}

export function instancesFor(entries, { placement, category }) {
  const placed = (entries ?? []).filter((entry) =>
    placementMatches(entry, placement)
  );

  const scoped = placed.filter(
    (entry) => entry.categories?.length && scopeMatches(entry, category)
  );
  if (scoped.length) {
    return scoped;
  }

  return placed.filter((entry) => !entry.categories?.length);
}
