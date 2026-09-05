import Component from "@glimmer/component";
import { trustHTML } from "@ember/template";
import dEmoji from "discourse/ui-kit/helpers/d-emoji";
import dIcon from "discourse/ui-kit/helpers/d-icon";

// The category's visual mark in whatever style the category uses: its emoji,
// its icon, or a colour square.
export default class CategoryMark extends Component {
  get style() {
    return trustHTML(`--category-badge-color: #${this.args.category.color}`);
  }

  <template>
    <span
      class="category-mark --{{@category.style_type}}"
      style={{this.style}}
      aria-hidden="true"
    >
      {{#if (eq @category.style_type "emoji")}}
        {{dEmoji @category.emoji}}
      {{else if (eq @category.style_type "icon")}}
        {{dIcon @category.icon}}
      {{else}}
        <span class="category-mark__square"></span>
      {{/if}}
    </span>
  </template>
}

function eq(a, b) {
  return a === b;
}
