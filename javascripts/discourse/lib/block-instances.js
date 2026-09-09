// The one place scoping logic lives. An entry of an objects setting applies
// when its category scope matches the page:
//
//   - a scoped entry (categories set) matches when the current category or
//     its parent is listed
//   - an unscoped entry (no categories) is the fallback: it applies only when
//     no scoped entry of the same setting matches the page
//
// So one default covers the whole site, and an entry for a space replaces the
// default there. Blocks use the first entry returned.

export function rootCategory(category) {
  return category?.parentCategory ?? category ?? null;
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

export function instancesFor(entries, { category }) {
  const all = entries ?? [];

  const scoped = all.filter(
    (entry) => entry.categories?.length && scopeMatches(entry, category)
  );
  if (scoped.length) {
    return scoped;
  }

  return all.filter((entry) => !entry.categories?.length);
}
