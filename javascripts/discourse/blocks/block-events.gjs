import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import BlockPanelError from "../components/block-panel-error";
import { fetchEvents } from "../lib/events";

// The layout selects the events entry for the current category and passes
// its events category here. Without one the events come from the whole
// site. With no upcoming events it shows the most recent past ones under
// @recentTitle. The data loads before the panel exists: nothing renders
// while loading or when there are no events at all, so an empty panel never
// flashes, and the panel disappears for good when the events plugin is
// missing.
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
  @tracked retryCount = 0;

  titleFor = (data) =>
    i18n(themePrefix(data.recent ? this.args.recentTitle : this.args.title));

  @bind
  retry() {
    this.retryCount++;
  }

  get eventsUrl() {
    return getURL("/upcoming-events");
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
      return await fetchEvents({ categoryId, count });
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
      <DAsyncContent
        @asyncData={{this.fetchEvents}}
        @context={{this.context}}
        @retainWhileReloading={{true}}
      >
        <:loading></:loading>
        <:empty></:empty>
        <:content as |data|>
          <BlockPanel
            @title={{this.titleFor data}}
            @icon={{@icon}}
            @mobile={{@mobile}}
            class="block-events"
          >
            <:content>
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
            <:footer>
              <a class="block-panel__link" href={{this.eventsUrl}}>
                {{i18n (themePrefix "events.view_all")}}
              </a>
            </:footer>
          </BlockPanel>
        </:content>
        <:error>
          <BlockPanel
            @title={{i18n (themePrefix @title)}}
            @icon={{@icon}}
            @mobile={{@mobile}}
            class="block-events"
          >
            <:content>
              <BlockPanelError @onRetry={{this.retry}} />
            </:content>
          </BlockPanel>
        </:error>
      </DAsyncContent>
    {{/unless}}
  </template>
}
