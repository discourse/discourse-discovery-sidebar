import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import { fetchEvents } from "../lib/events";

// The layout selects the events entry for the current category and passes
// its events category here. Without one the events come from the whole
// site. The panel disappears for good when the events plugin is missing.
@block("theme:discovery-sidebar:events", {
  description: "Upcoming post events of a category",
  args: {
    title: { type: "string", required: true },
    recentTitle: { type: "string", required: true },
    icon: { type: "string" },
    mobile: { type: "boolean", default: false },
    categoryId: { type: "number", integer: true, min: 1 },
    count: { type: "number", default: 3 },
  },
})
export default class BlockEvents extends Component {
  @tracked unavailable = false;
  @tracked recent = false;
  @tracked retryCount = 0;

  @bind
  retry() {
    this.retryCount++;
  }

  get title() {
    return i18n(
      themePrefix(this.recent ? this.args.recentTitle : this.args.title)
    );
  }

  get eventsUrl() {
    return getURL("/upcoming-events");
  }

  get skeleton() {
    return { rows: "event", count: this.args.count };
  }

  get context() {
    return {
      categoryId: this.args.categoryId,
      count: this.args.count,
      retryCount: this.retryCount,
    };
  }

  @bind
  async fetchEvents({ categoryId, count }) {
    try {
      const result = await fetchEvents({ categoryId, count });
      if (!this.isDestroying && !this.isDestroyed) {
        this.recent = !!result?.recent;
      }
      return result;
    } catch (error) {
      if (error.jqXHR?.status === 403 || error.jqXHR?.status === 404) {
        if (!this.isDestroying && !this.isDestroyed) {
          this.unavailable = true;
        }
        return null;
      }
      throw error;
    }
  }

  <template>
    {{#unless this.unavailable}}
      <BlockPanel
        @title={{this.title}}
        @icon={{@icon}}
        @mobile={{@mobile}}
        @asyncData={{this.fetchEvents}}
        @context={{this.context}}
        @skeleton={{this.skeleton}}
        @onRetry={{this.retry}}
        class="block-events"
      >
        <:content as |data|>
          <ol class="block-events__list">
            {{#each data.events as |event|}}
              <li class="block-events__row">
                <a class="block-events__link" href={{event.url}}>
                  <time class="block-events__date" datetime={{event.iso}}>
                    <span class="block-events__month">{{event.month}}</span>
                    <span class="block-events__day">{{event.day}}</span>
                  </time>
                  <span class="block-events__name">{{event.title}}</span>
                </a>
              </li>
            {{/each}}
          </ol>
        </:content>
        <:empty>
          <p class="block-events__empty">
            {{i18n (themePrefix "events.empty")}}
          </p>
        </:empty>
        <:footer>
          <a class="block-panel__link" href={{this.eventsUrl}}>
            {{i18n (themePrefix "events.view_all")}}
          </a>
        </:footer>
      </BlockPanel>
    {{/unless}}
  </template>
}
