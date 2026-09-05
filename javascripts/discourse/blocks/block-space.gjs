import Component from "@glimmer/component";
import { service } from "@ember/service";
import { settings, themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import CategoryMark from "../components/category-mark";
import { instancesFor, rootCategory } from "../lib/block-instances";

// The current space: the top-level category of the page and all its
// subcategories, the current one highlighted. On global lists (Latest, Top,
// tags) the panel lists every top-level category instead. Data is synchronous
// from the site's category list, so there is no loading state.
@block("theme:discovery-sidebar:space", {
  description: "The current top-level category and its subcategories",
  args: {
    placement: { type: "string", enum: ["discovery-sidebar"], required: true },
  },
})
export default class BlockSpace extends Component {
  @service discovery;
  @service site;

  isCurrent = (category) => category.id === this.category?.id;

  get homeUrl() {
    return getURL("/");
  }

  get category() {
    return this.discovery.category;
  }

  get space() {
    return rootCategory(this.category);
  }

  get subcategories() {
    return this.visible(this.space?.subcategories ?? []);
  }

  get topLevelCategories() {
    return this.visible(
      this.site.categories.filter((c) => !c.parent_category_id)
    );
  }

  get instances() {
    return instancesFor(settings.space, {
      placement: this.args.placement,
      category: this.category,
    });
  }

  visible(categories) {
    return categories.filter((c) => !c.isHidden && !c.isUncategorizedCategory);
  }

  <template>
    {{#each this.instances key="title" as |instance|}}
      {{#if this.space}}
        <BlockPanel
          @title={{instance.title}}
          @mobile={{instance.mobile}}
          class="block-space"
        >
          <:content>
            <div
              class="block-space__intro
                {{if (this.isCurrent this.space) '--current'}}"
            >
              <a class="block-space__head" href={{this.space.url}}>
                <CategoryMark @category={{this.space}} />
                <span class="block-space__name">{{this.space.name}}</span>
              </a>
              {{#if instance.show_description}}
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
                    <a class="block-space__link" href={{subcategory.url}}>
                      <CategoryMark @category={{subcategory}} />
                      <span
                        class="block-space__name"
                      >{{subcategory.name}}</span>
                      {{#if instance.show_topic_counts}}
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
            <a class="block-panel__link" href={{this.homeUrl}}>
              {{i18n (themePrefix "space.all_spaces_link")}}
            </a>
          </:footer>
        </BlockPanel>
      {{else if this.topLevelCategories.length}}
        <BlockPanel
          @title={{if
            instance.title
            instance.title
            (i18n (themePrefix "space.all_spaces"))
          }}
          @icon="compass"
          @mobile={{instance.mobile}}
          class="block-space --global"
        >
          <:content>
            <ul class="block-space__list">
              {{#each this.topLevelCategories as |category|}}
                <li class="block-space__item">
                  <a class="block-space__link" href={{category.url}}>
                    <CategoryMark @category={{category}} />
                    <span class="block-space__name">{{category.name}}</span>
                    {{#if instance.show_topic_counts}}
                      <span class="block-space__count">
                        {{i18n
                          (themePrefix "space.topic_count")
                          count=category.topic_count
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
    {{/each}}
  </template>
}
