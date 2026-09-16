import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import TopicLink from "discourse/components/topic-list/topic-link";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import Category from "discourse/models/category";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import { spaceOf } from "../lib/space";

// The layout selects the topic list entry for the current category and
// passes its list, period and tag here. Topics come from the current space
// and its subcategories, or from the whole site on global lists. Pinned
// topics are left out: they already sit on top of the main list.
@block("theme:discovery-sidebar:topics", {
  description: "A compact topic list of the current space",
  args: {
    title: { type: "string", required: true },
    icon: { type: "string" },
    mobile: { type: "boolean", default: false },
    list: { type: "string", default: "hot", enum: ["latest", "hot", "top"] },
    period: {
      type: "string",
      default: "monthly",
      enum: ["all", "yearly", "quarterly", "monthly", "weekly", "daily"],
    },
    tag: { type: "string" },
    count: { type: "number", default: 5 },
    showCategory: { type: "boolean", default: true },
  },
})
export default class BlockTopics extends Component {
  @service discovery;
  @service store;

  @tracked retryCount = 0;

  @bind
  retry() {
    this.retryCount++;
  }

  get space() {
    return spaceOf(this.discovery.category);
  }

  get filter() {
    const { list, tag } = this.args;
    const space = this.space;
    const categoryPath = space
      ? `c/${Category.slugFor(space)}/${space.id}`
      : null;
    const tagPath = tag ? encodeURIComponent(tag) : null;

    if (categoryPath && tagPath) {
      return `tags/${categoryPath}/${tagPath}/l/${list}`;
    }
    if (tagPath) {
      return `tag/${tagPath}/l/${list}`;
    }
    if (categoryPath) {
      return `${categoryPath}/l/${list}`;
    }
    return list;
  }

  get params() {
    return this.args.list === "top" ? { period: this.args.period } : undefined;
  }

  get viewAllUrl() {
    const url = getURL(`/${this.filter}`);
    return this.params ? `${url}?period=${this.params.period}` : url;
  }

  get skeleton() {
    return { rows: "topic", count: this.args.count };
  }

  get context() {
    return {
      filter: this.filter,
      params: this.params,
      count: this.args.count,
      retryCount: this.retryCount,
    };
  }

  @bind
  async fetchTopics({ filter, params, count }) {
    const list = await this.store.findFiltered("topicList", { filter, params });
    const topics =
      list.topics?.filter((topic) => !topic.pinned).slice(0, count) ?? [];
    return topics.length ? topics : null;
  }

  <template>
    <BlockPanel
      @title={{i18n (themePrefix @title)}}
      @icon={{@icon}}
      @mobile={{@mobile}}
      @asyncData={{this.fetchTopics}}
      @context={{this.context}}
      @skeleton={{this.skeleton}}
      @onRetry={{this.retry}}
      class="block-topics"
    >
      <:content as |topics|>
        <ol class="block-topics__list">
          {{#each topics as |topic|}}
            <li class="block-topics__row">
              <TopicLink @topic={{topic}} class="block-topics__title" />
              <span class="block-topics__meta">
                {{#if @showCategory}}
                  {{#if topic.category}}
                    {{dCategoryLink topic.category}}
                  {{/if}}
                {{/if}}
                <a class="block-topics__date" href={{topic.lastPostUrl}}>
                  {{dFormatDate topic.bumpedAt format="tiny" noTitle="true"}}
                </a>
              </span>
            </li>
          {{/each}}
        </ol>
      </:content>
      <:empty>
        <p class="block-topics__empty">
          {{i18n (themePrefix "topics.empty")}}
        </p>
      </:empty>
      <:footer>
        <a class="block-panel__link" href={{this.viewAllUrl}}>
          {{i18n (themePrefix "topics.view_all")}}
        </a>
      </:footer>
    </BlockPanel>
  </template>
}
