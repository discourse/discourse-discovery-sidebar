export function categoryScope(categories) {
  return {
    any: [
      { type: "outlet-arg", path: "category.id", value: categories },
      {
        type: "outlet-arg",
        path: "category.parent_category_id",
        value: categories,
      },
    ],
  };
}

export function scopedEntries(entries) {
  return (entries ?? []).filter((entry) => entry.categories?.length);
}

// An array makes spreading the optional fallback into a layout concise. An
// empty result means no layout child is created, so no block renders.
export function defaultEntries(entries) {
  const entry = (entries ?? []).find((item) => !item.categories?.length);
  return entry ? [entry] : [];
}

export function withoutEmptyContainers(entries) {
  return entries.flatMap((entry) => {
    if (!entry.children) {
      return [entry];
    }
    const children = withoutEmptyContainers(entry.children);
    return children.length ? [{ ...entry, children }] : [];
  });
}
