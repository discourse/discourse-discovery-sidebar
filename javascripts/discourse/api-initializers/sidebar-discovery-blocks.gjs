import { settings } from "virtual:theme";
import BlockGroup from "discourse/blocks/builtin/block-group";
import BlockHead from "discourse/blocks/builtin/block-head";
import { apiInitializer } from "discourse/lib/api";
import BlockLeaderboard from "../blocks/block-leaderboard";
import BlockResources from "../blocks/block-resources";
import BlockSpace from "../blocks/block-space";
import {
  categoryScope,
  defaultEntries,
  scopedEntries,
} from "../lib/category-scoped-layout";

export default apiInitializer((api) => {
  api.renderBlocks("sidebar-discovery", [
    {
      block: BlockGroup,
      id: "topic-lists",
      conditions: {
        not: { type: "route", urls: ["/categories", "/categories/**"] },
      },
      children: [
        {
          block: BlockSpace,
          id: "space",
          args: {
            title: "space.all_spaces",
            icon: "compass",
            mobile: true,
            showDescription: true,
            showTopicCounts: true,
          },
        },
        {
          block: BlockHead,
          id: "leaderboard",
          children: [
            ...scopedEntries(settings.leaderboards).map((entry) => ({
              block: BlockLeaderboard,
              args: {
                title: "leaderboard.title",
                icon: "trophy",
                mobile: false,
                count: 5,
                period: "monthly",
                leaderboardId: entry.leaderboard_id,
              },
              conditions: categoryScope(entry.categories),
            })),
            ...defaultEntries(settings.leaderboards).map((entry) => ({
              block: BlockLeaderboard,
              args: {
                title: "leaderboard.title",
                icon: "trophy",
                mobile: false,
                count: 5,
                period: "monthly",
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
  ]);
});
