import Component from "@glimmer/component";
import { service } from "@ember/service";
import { settings, themePrefix } from "virtual:theme";
import { block } from "discourse/blocks";
import getURL from "discourse/lib/get-url";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import BlockPanel from "../components/block-panel";
import { instancesFor } from "../lib/block-instances";

function isExternal(url) {
  try {
    return (
      new URL(url, window.location.origin).origin !== window.location.origin
    );
  } catch {
    return false;
  }
}

function normalizeLink(link) {
  const url = link.url?.trim();
  if (!link.label?.trim() || !url) {
    return null;
  }
  const external = isExternal(url);
  return {
    label: link.label.trim(),
    description: link.description?.trim() || null,
    icon: link.icon?.trim() || null,
    url: external ? url : getURL(url.startsWith("/") ? url : `/${url}`),
    external,
  };
}

// The resource links for the current category, from the `resources` setting:
// the entry scoped to the category, else the unscoped default. Link fields
// follow core's link-list block (label, url, icon, description) so the content
// transfers to it unchanged.
@block("theme:discovery-sidebar:resources", {
  description: "A titled list of resource links",
})
export default class BlockResources extends Component {
  @service discovery;

  get links() {
    const entry = instancesFor(settings.resources, {
      category: this.discovery.category,
    })[0];
    return (entry?.links ?? []).map(normalizeLink).filter(Boolean);
  }

  <template>
    {{#if this.links.length}}
      <BlockPanel
        @title={{i18n (themePrefix "resources.title")}}
        @icon="book"
        class="block-resources"
      >
        <:content>
          <ul class="block-resources__list">
            {{#each this.links as |link|}}
              <li class="block-resources__item">
                <a
                  class="block-resources__link"
                  href={{link.url}}
                  target={{if link.external "_blank"}}
                  rel={{if link.external "noopener noreferrer"}}
                >
                  {{#if link.icon}}
                    <span class="block-resources__icon">{{dIcon
                        link.icon
                      }}</span>
                  {{/if}}
                  <span class="block-resources__text">
                    <span class="block-resources__label">{{link.label}}</span>
                    {{#if link.description}}
                      <span
                        class="block-resources__description"
                      >{{link.description}}</span>
                    {{/if}}
                  </span>
                </a>
              </li>
            {{/each}}
          </ul>
        </:content>
      </BlockPanel>
    {{/if}}
  </template>
}
