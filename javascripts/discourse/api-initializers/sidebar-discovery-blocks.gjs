import BlockGroup from "discourse/blocks/builtin/block-group";
import { apiInitializer } from "discourse/lib/api";
import BlockLeaderboard from "../blocks/block-leaderboard";
import BlockResources from "../blocks/block-resources";
import BlockSpace from "../blocks/block-space";

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
        },
        {
          block: BlockLeaderboard,
          id: "leaderboard",
        },
        {
          block: BlockResources,
          id: "resources",
        },
      ],
    },
  ]);
});
