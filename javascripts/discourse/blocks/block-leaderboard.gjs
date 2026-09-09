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

// The leaderboard from the `leaderboards` setting: the entry scoped to the
// current category, else the unscoped default. No matching entry renders
// nothing; an entry without an id shows the plugin's default leaderboard. Arg
// names follow the gamification plugin's block on core's wireframe branch
// (count, period).
@block("theme:discovery-sidebar:leaderboard", {
  description: "Top users of a gamification leaderboard",
  args: {
    title: { type: "string", required: true },
    icon: { type: "string" },
    mobile: { type: "boolean", default: false },
    count: { type: "number", default: 5 },
    period: {
      type: "string",
      default: "monthly",
      enum: ["all_time", "yearly", "quarterly", "monthly", "weekly", "daily"],
    },
  },
})
export default class BlockLeaderboard extends Component {
  @service discovery;
  @service siteSettings;

  displayName = (user) =>
    this.siteSettings.prioritize_username_in_ux
      ? user.username
      : user.name || user.username;

  get entry() {
    return instancesFor(settings.leaderboards, {
      category: this.discovery.category,
    })[0];
  }

  get path() {
    const id = this.entry?.leaderboard_id;
    return id ? `/leaderboard/${id}` : "/leaderboard";
  }

  get leaderboardUrl() {
    return getURL(this.path);
  }

  get skeleton() {
    return { rows: "user", count: this.args.count };
  }

  // DAsyncContent refetches when the context object changes; the path is the
  // context, so the panel reloads when the category picks another leaderboard.
  get context() {
    return { path: this.path };
  }

  @bind
  async fetchLeaderboard({ path }) {
    const result = await ajax(path, {
      data: { user_limit: this.args.count, period: this.args.period },
    });
    return result?.users?.length ? result : null;
  }

  <template>
    {{#if this.entry}}
      <BlockPanel
        @title={{i18n (themePrefix @title)}}
        @icon={{@icon}}
        @mobile={{@mobile}}
        @asyncData={{this.fetchLeaderboard}}
        @context={{this.context}}
        @skeleton={{this.skeleton}}
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
          <a class="block-panel__link" href={{this.leaderboardUrl}}>
            {{i18n (themePrefix "leaderboard.view_all")}}
          </a>
        </:footer>
      </BlockPanel>
    {{/if}}
  </template>
}
