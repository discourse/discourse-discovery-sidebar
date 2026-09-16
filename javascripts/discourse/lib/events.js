import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";

function occurrences(event) {
  const upcoming = (event.upcoming_dates ?? []).map((date) => date.starts_at);
  const starts = upcoming.length ? upcoming : [event.starts_at];
  return starts
    .filter(Boolean)
    .map((iso) => ({ iso, ms: new Date(iso).getTime() }))
    .filter((row) => !Number.isNaN(row.ms));
}

function nextOccurrence(event, now) {
  return occurrences(event)
    .filter((row) => row.ms >= now)
    .sort((a, b) => a.ms - b.ms)[0];
}

function lastOccurrence(event, now) {
  return occurrences(event)
    .filter((row) => row.ms < now)
    .sort((a, b) => b.ms - a.ms)[0];
}

function serialize([event, occurrence]) {
  const date = new Date(occurrence.iso);
  return {
    id: event.id,
    title: event.name?.trim() || event.post?.topic?.title || "",
    iso: occurrence.iso,
    month: new Intl.DateTimeFormat(undefined, { month: "short" }).format(date),
    day: date.getDate(),
    url: event.post?.url ? getURL(event.post.url) : null,
  };
}

// Post events of the whole site, or of a category and its subcategories
// when one is given. The next `count` upcoming events; when there are none,
// the `count` most recent past events instead, flagged with `recent`. Null
// when there are no events at all, so the panel shows its empty state.
export async function fetchEvents({ categoryId, count }) {
  const result = await ajax("/discourse-post-event/events.json", {
    data: {
      category_id: categoryId,
      include_subcategories: true,
      include_details: true,
      include_expired: true,
      limit: Math.min(Math.max(count * 5, 15), 100),
    },
  });
  const events = result?.events ?? [];
  const now = Date.now();

  const upcoming = events
    .map((event) => [event, nextOccurrence(event, now)])
    .filter(([, occurrence]) => occurrence)
    .sort(([, a], [, b]) => a.ms - b.ms)
    .slice(0, count)
    .map(serialize);

  if (upcoming.length) {
    return { events: upcoming, recent: false };
  }

  const recent = events
    .map((event) => [event, lastOccurrence(event, now)])
    .filter(([, occurrence]) => occurrence)
    .sort(([, a], [, b]) => b.ms - a.ms)
    .slice(0, count)
    .map(serialize);

  return recent.length ? { events: recent, recent: true } : null;
}
