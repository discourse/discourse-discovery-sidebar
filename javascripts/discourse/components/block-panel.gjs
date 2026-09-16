import DAsyncContent from "discourse/ui-kit/d-async-content";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import BlockPanelSkeleton from "./block-panel-skeleton";

// Chrome shared by every sidebar panel: header, body, footer. The header and
// footer render from args and stay visible while data loads; only the body is
// inside the data boundary, where a reserved-space skeleton replaces the
// spinner. Sync panels omit @asyncData and yield their content directly.
//
// @title, @icon        header
// @mobile              instance stays visible in the single-column layout
// @asyncData, @context passed to DAsyncContent; @skeleton shapes the placeholder
// <:content as |data|> body; <:empty>; <:error>; <:footer>
const BlockPanel = <template>
  <section class="block-panel {{if @mobile '--mobile'}}" ...attributes>
    {{#if @title}}
      <header class="block-panel__header">
        {{#if @icon}}
          <span class="block-panel__icon">{{dIcon @icon}}</span>
        {{/if}}
        <h3 class="block-panel__title">{{@title}}</h3>
      </header>
    {{/if}}

    <div class="block-panel__body">
      {{#if @asyncData}}
        <DAsyncContent
          @asyncData={{@asyncData}}
          @context={{@context}}
          @retainWhileReloading={{true}}
        >
          <:loading>
            <div class="block-panel__loading" aria-busy="true">
              <BlockPanelSkeleton @shape={{@skeleton}} />
            </div>
          </:loading>
          <:content as |data|>
            {{yield data to="content"}}
          </:content>
          <:error as |error InlineError|>
            {{#if (has-block "error")}}
              {{yield error to="error"}}
            {{else}}
              <InlineError />
            {{/if}}
          </:error>
          <:empty>
            {{yield to="empty"}}
          </:empty>
        </DAsyncContent>
      {{else}}
        {{yield null to="content"}}
      {{/if}}
    </div>

    {{#if (has-block "footer")}}
      <footer class="block-panel__footer">
        {{yield to="footer"}}
      </footer>
    {{/if}}
  </section>
</template>;

export default BlockPanel;
