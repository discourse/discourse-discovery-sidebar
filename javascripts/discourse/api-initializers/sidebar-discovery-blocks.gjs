import { settings } from "virtual:theme";
import BlockGroup from "discourse/blocks/builtin/block-group";
import BlockHead from "discourse/blocks/builtin/block-head";
import { apiInitializer } from "discourse/lib/api";
import BlockEvents from "../blocks/block-events";
import BlockLeaderboard from "../blocks/block-leaderboard";
import BlockResources from "../blocks/block-resources";
import BlockSpace from "../blocks/block-space";
import BlockTopics from "../blocks/block-topics";
import {
  categoryScope,
  defaultEntries,
  scopedEntries,
  withoutEmptyContainers,
} from "../lib/category-scoped-layout";

export default apiInitializer((api) => {
  api.renderBlocks(
    "sidebar-discovery",
    withoutEmptyContainers([
      {
        block: BlockGroup,
        conditions: {
          not: { type: "route", urls: ["/categories", "/categories/**"] },
        },
        children: [
          {
            block: BlockHead,
            id: "space",
            children: [
              ...scopedEntries(settings.spaces).map((entry) => ({
                block: BlockSpace,
                args: {
                  title: "space.all_spaces",
                  icon: "compass",
                  mobile: true,
                  showDescription: true,
                  showTopicCounts: true,
                  allSpacesUrl: entry.all_spaces_url,
                },
                conditions: categoryScope(entry.categories),
              })),
              ...defaultEntries(settings.spaces).map((entry) => ({
                block: BlockSpace,
                args: {
                  title: "space.all_spaces",
                  icon: "compass",
                  mobile: true,
                  showDescription: true,
                  showTopicCounts: true,
                  allSpacesUrl: entry.all_spaces_url,
                },
              })),
            ],
          },
          {
            block: BlockHead,
            id: "events",
            children: [
              ...scopedEntries(settings.events).map((entry) => ({
                block: BlockEvents,
                args: {
                  title: "events.title",
                  recentTitle: "events.recent",
                  icon: "calendar",
                  mobile: false,
                  count: 3,
                  categoryId: entry.events_category?.[0],
                },
                conditions: categoryScope(entry.categories),
              })),
              ...defaultEntries(settings.events).map((entry) => ({
                block: BlockEvents,
                args: {
                  title: "events.title",
                  recentTitle: "events.recent",
                  icon: "calendar",
                  mobile: false,
                  count: 3,
                  categoryId: entry.events_category?.[0],
                },
              })),
            ],
          },
          {
            block: BlockHead,
            id: "topics",
            children: [
              ...scopedEntries(settings.topic_lists).map((entry) => ({
                block: BlockTopics,
                args: {
                  title: "topics.title",
                  icon: "comments",
                  mobile: false,
                  count: 5,
                  showCategory: true,
                  order: entry.order,
                  tag: entry.tag?.[0],
                },
                conditions: categoryScope(entry.categories),
              })),
              ...defaultEntries(settings.topic_lists).map((entry) => ({
                block: BlockTopics,
                args: {
                  title: "topics.title",
                  icon: "comments",
                  mobile: false,
                  count: 5,
                  showCategory: true,
                  order: entry.order,
                  tag: entry.tag?.[0],
                },
              })),
            ],
          },
          {
            block: BlockHead,
            id: "leaderboard",
            children: [
              ...scopedEntries(settings.leaderboards).map((entry) => ({
                block: BlockLeaderboard,
                args: {
                  icon: "trophy",
                  mobile: false,
                  count: 8,
                  leaderboardId: entry.leaderboard_id,
                },
                conditions: categoryScope(entry.categories),
              })),
              ...defaultEntries(settings.leaderboards).map((entry) => ({
                block: BlockLeaderboard,
                args: {
                  icon: "trophy",
                  mobile: false,
                  count: 8,
                  leaderboardId: entry.leaderboard_id,
                },
              })),
            ],
          },
          {
            block: BlockHead,
            id: "resources",
            children: [
              ...scopedEntries(settings.resources).map((entry) => ({
                block: BlockResources,
                args: {
                  title: "resources.title",
                  icon: "book",
                  mobile: false,
                  links: entry.links,
                },
                conditions: categoryScope(entry.categories),
              })),
              ...defaultEntries(settings.resources).map((entry) => ({
                block: BlockResources,
                args: {
                  title: "resources.title",
                  icon: "book",
                  mobile: false,
                  links: entry.links,
                },
              })),
            ],
          },
        ],
      },
    ])
  );
});
