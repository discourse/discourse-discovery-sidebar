import Component from "@glimmer/component";
import { service } from "@ember/service";
import { themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import CategoryMark from "../components/category-mark";
import { spaceOf } from "../lib/space";

// The current space: the top-level category of the page and all its
// subcategories, the current one highlighted. On global lists (Latest, Top,
// tags) the panel lists every top-level category instead, under @title. All
// content comes from the route and the site's category list, so there is no
// data setting and no loading state; the args are display choices. The
// spaces setting decides on which categories the layout renders it and where
// its "All spaces" link goes.
@block("theme:discovery-sidebar:space", {
  description: "The current top-level category and its subcategories",
  args: {
    title: { type: "string", required: true },
    icon: { type: "string" },
    mobile: { type: "boolean", default: false },
    showDescription: { type: "boolean", default: true },
    showTopicCounts: { type: "boolean", default: true },
    allSpacesUrl: {
      type: "string",
      default: "/",
      enum: ["/", "/latest", "/categories"],
    },
  },
})
export default class BlockSpace extends Component {
  @service discovery;
  @service site;

  isCurrent = (category) => category.id === this.category?.id;

  get allSpacesUrl() {
    return getURL(this.args.allSpacesUrl ?? "/");
  }

  get category() {
    return this.discovery.category;
  }

  get space() {
    return spaceOf(this.category);
  }

  get subcategories() {
    return this.visible(this.space?.subcategories ?? []);
  }

  get topLevelCategories() {
    return this.visible(
      this.site.categories.filter((c) => !c.parent_category_id)
    );
  }

  visible(categories) {
    return categories.filter((c) => !c.isHidden && !c.isUncategorizedCategory);
  }

  <template>
    {{#if this.space}}
      <BlockPanel @mobile={{@mobile}} class="block-space">
        <:content>
          <div
            class="block-space__intro
              {{if (this.isCurrent this.space) '--current'}}"
          >
            <a
              class="block-space__head"
              href={{this.space.url}}
              aria-current={{if (this.isCurrent this.space) "page"}}
            >
              <CategoryMark @category={{this.space}} />
              <span class="block-space__name">{{this.space.name}}</span>
              {{#if @showTopicCounts}}
                <span class="block-space__count">
                  {{i18n
                    (themePrefix "space.topic_count")
                    count=this.space.totalTopicCount
                  }}
                </span>
              {{/if}}
            </a>
            {{#if @showDescription}}
              {{#if this.space.description_text}}
                <p
                  class="block-space__description"
                >{{this.space.description_text}}</p>
              {{/if}}
            {{/if}}
          </div>

          {{#if this.subcategories.length}}
            <ul class="block-space__list">
              {{#each this.subcategories as |subcategory|}}
                <li
                  class="block-space__item
                    {{if (this.isCurrent subcategory) '--current'}}"
                >
                  <a
                    class="block-space__link"
                    href={{subcategory.url}}
                    aria-current={{if (this.isCurrent subcategory) "page"}}
                  >
                    <CategoryMark @category={{subcategory}} />
                    <span class="block-space__name">{{subcategory.name}}</span>
                    {{#if @showTopicCounts}}
                      <span class="block-space__count">
                        {{i18n
                          (themePrefix "space.topic_count")
                          count=subcategory.topic_count
                        }}
                      </span>
                    {{/if}}
                  </a>
                </li>
              {{/each}}
            </ul>
          {{/if}}
        </:content>
        <:footer>
          <a class="block-panel__link" href={{this.allSpacesUrl}}>
            {{i18n (themePrefix "space.all_spaces_link")}}
          </a>
        </:footer>
      </BlockPanel>
    {{else if this.topLevelCategories.length}}
      <BlockPanel
        @title={{i18n (themePrefix @title)}}
        @icon={{@icon}}
        @mobile={{@mobile}}
        class="block-space --global"
      >
        <:content>
          <ul class="block-space__list">
            {{#each this.topLevelCategories as |category|}}
              <li class="block-space__item">
                <a class="block-space__link" href={{category.url}}>
                  <CategoryMark @category={{category}} />
                  <span class="block-space__name">{{category.name}}</span>
                  {{#if @showTopicCounts}}
                    <span class="block-space__count">
                      {{i18n
                        (themePrefix "space.topic_count")
                        count=category.totalTopicCount
                      }}
                    </span>
                  {{/if}}
                </a>
              </li>
            {{/each}}
          </ul>
        </:content>
      </BlockPanel>
    {{/if}}
  </template>
}
