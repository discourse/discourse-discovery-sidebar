// The space of a category page is its top-level category: a subcategory page
// belongs to the parent's space. No category means a global list.
export function spaceOf(category) {
  return category?.parentCategory ?? category ?? null;
}
