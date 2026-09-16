import Component from "@glimmer/component";
import DSkeleton from "discourse/ui-kit/d-skeleton";

// Loading placeholder for a panel body. The shape follows core's
// BlockSkeletonShape (variant, count, width, height) so it can move into a
// block's `data.skeleton` declaration later. `rows` is a theme extension for
// composed rows that plain DSkeleton cannot express:
//   { rows: "user", count }  avatar circle + name line + score
//   { rows: "link", count }  icon square + label line + description line
export default class BlockPanelSkeleton extends Component {
  get rows() {
    const count = this.args.shape?.count ?? 5;
    return Array.from({ length: count }, (_, index) => index);
  }

  <template>
    <div class="block-panel-skeleton" aria-hidden="true">
      {{#if (eq @shape.rows "user")}}
        {{#each this.rows as |row|}}
          <div class="block-panel-skeleton__row --user" data-row={{row}}>
            <DSkeleton @variant="circle" @size="1.75rem" />
            <DSkeleton @variant="text" @width="55%" />
            <DSkeleton @variant="text" @width="2.5rem" />
          </div>
        {{/each}}
      {{else if (eq @shape.rows "link")}}
        {{#each this.rows as |row|}}
          <div class="block-panel-skeleton__row --link" data-row={{row}}>
            <DSkeleton @variant="rect" @width="1.25rem" @height="1.25rem" />
            <div class="block-panel-skeleton__lines">
              <DSkeleton @variant="text" @width="60%" />
              <DSkeleton @variant="text" @width="85%" />
            </div>
          </div>
        {{/each}}
      {{else}}
        <DSkeleton
          @variant={{@shape.variant}}
          @count={{@shape.count}}
          @width={{@shape.width}}
          @height={{@shape.height}}
        />
      {{/if}}
    </div>
  </template>
}

function eq(a, b) {
  return a === b;
}
