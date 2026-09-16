import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DUserAvatar from "discourse/ui-kit/d-user-avatar";
import DUserLink from "discourse/ui-kit/d-user-link";
import dNumber from "discourse/ui-kit/helpers/d-number";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";

// The layout selects the leaderboard for the current category and passes its
// id here. A missing id deliberately uses the Gamification plugin's default.
// Arg names follow its core block (leaderboardId, count, period).
@block("theme:discovery-sidebar:leaderboard", {
  description: "Top users of a gamification leaderboard",
  args: {
    title: { type: "string", required: true },
    icon: { type: "string" },
    mobile: { type: "boolean", default: false },
    leaderboardId: { type: "number", integer: true, min: 1 },
    count: { type: "number", default: 5 },
    period: {
      type: "string",
      default: "monthly",
      enum: ["all_time", "yearly", "quarterly", "monthly", "weekly", "daily"],
    },
  },
})
export default class BlockLeaderboard extends Component {
  @service siteSettings;

  @tracked unavailablePath;
  @tracked retryCount = 0;

  displayName = (user) =>
    this.siteSettings.prioritize_username_in_ux
      ? user.username
      : user.name || user.username;

  get unavailable() {
    return this.unavailablePath === this.path;
  }

  @bind
  retry() {
    this.retryCount++;
  }

  get path() {
    const id = this.args.leaderboardId;
    return id ? `/leaderboard/${id}` : "/leaderboard";
  }

  get leaderboardUrl() {
    return getURL(this.path);
  }

  get skeleton() {
    return { rows: "user", count: this.args.count };
  }

  get context() {
    return {
      path: this.path,
      count: this.args.count,
      period: this.args.period,
      retryCount: this.retryCount,
    };
  }

  @bind
  async fetchLeaderboard({ path, count, period }) {
    try {
      const result = await ajax(path, {
        data: { user_limit: count, period },
      });
      return result?.users?.length ? result : null;
    } catch (error) {
      if (error.jqXHR?.status === 403 || error.jqXHR?.status === 404) {
        if (!this.isDestroying && !this.isDestroyed && path === this.path) {
          this.unavailablePath = path;
        }
        return null;
      }
      throw error;
    }
  }

  <template>
    {{#unless this.unavailable}}
      <BlockPanel
        @title={{i18n (themePrefix @title)}}
        @icon={{@icon}}
        @mobile={{@mobile}}
        @asyncData={{this.fetchLeaderboard}}
        @context={{this.context}}
        @skeleton={{this.skeleton}}
        @onRetry={{this.retry}}
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
    {{/unless}}
  </template>
}
