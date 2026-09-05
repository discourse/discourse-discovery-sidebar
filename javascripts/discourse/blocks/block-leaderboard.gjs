import Component from "@glimmer/component";
import { service } from "@ember/service";
import { settings, themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DUserAvatar from "discourse/ui-kit/d-user-avatar";
import DUserLink from "discourse/ui-kit/d-user-link";
import dNumber from "discourse/ui-kit/helpers/d-number";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import { instancesFor } from "../lib/block-instances";

// A gamification leaderboard per instance. Arg names follow the gamification
// plugin's block on core's wireframe branch (leaderboardId, count, period).
@block("theme:discovery-sidebar:leaderboard", {
  description: "Top users of a gamification leaderboard",
  args: {
    placement: { type: "string", enum: ["discovery-sidebar"], required: true },
  },
})
export default class BlockLeaderboard extends Component {
  @service discovery;
  @service siteSettings;

  leaderboardUrl = (instance, data) => {
    const id = instance.leaderboard_id || data?.leaderboard?.id;
    return getURL(id ? `/leaderboard/${id}` : "/leaderboard");
  };

  skeletonFor = (instance) => ({ rows: "user", count: instance.count ?? 5 });

  displayName = (user) =>
    this.siteSettings.prioritize_username_in_ux
      ? user.username
      : user.name || user.username;

  get instances() {
    return instancesFor(settings.leaderboard, {
      placement: this.args.placement,
      category: this.discovery.category,
    });
  }

  // DAsyncContent refetches when the context object changes; the instance is
  // the context, so each panel loads its own leaderboard.
  @bind
  async fetchLeaderboard(instance) {
    const path = instance.leaderboard_id
      ? `/leaderboard/${instance.leaderboard_id}`
      : "/leaderboard";
    const result = await ajax(path, {
      data: {
        user_limit: instance.count ?? 5,
        period: instance.period ?? "monthly",
      },
    });
    return result?.users?.length ? result : null;
  }

  <template>
    {{#each this.instances key="title" as |instance|}}
      <BlockPanel
        @title={{instance.title}}
        @icon={{instance.title_icon}}
        @mobile={{instance.mobile}}
        @asyncData={{this.fetchLeaderboard}}
        @context={{instance}}
        @skeleton={{this.skeletonFor instance}}
        class="block-leaderboard"
      >
        <:content as |data|>
          <ol class="block-leaderboard__list">
            {{#each data.users as |user|}}
              <li class="block-leaderboard__row">
                <span class="block-leaderboard__rank">{{user.position}}</span>
                <DUserAvatar @user={{user}} @size="small" />
                <DUserLink @user={{user}} class="block-leaderboard__name">
                  {{this.displayName user}}
                </DUserLink>
                <span class="block-leaderboard__score">
                  {{dNumber user.total_score}}
                </span>
              </li>
            {{/each}}
          </ol>
        </:content>
        <:empty>
          <p class="block-leaderboard__empty">
            {{i18n (themePrefix "leaderboard.empty")}}
          </p>
        </:empty>
        <:footer>
          <a
            class="block-panel__link"
            href={{this.leaderboardUrl instance}}
          >{{i18n (themePrefix "leaderboard.view_all")}}</a>
        </:footer>
      </BlockPanel>
    {{/each}}
  </template>
}
