import Component from "@glimmer/component";
import { action, get } from "@ember/object";
import I18n from "discourse-i18n";
import { i18n } from "discourse-i18n";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DeleteUploadsModal from "../../components/modal/delete-uploads-modal";

export default class LegalComplianceDeleteUploadsButton extends Component {
  @service modal;

  get mustShow() {
    return this.args.outletArgs.reviewable.type == "ReviewableFlaggedPost" &&
      this.args.outletArgs.reviewable?.raw?.includes("upload://");
  }

  @action
  openDeletionModal() {
    this.modal.show(DeleteUploadsModal, {
      model: {
        post: { id: this.args.outletArgs.reviewable?.post_id },
      }
    });
  }

  <template>
    {{#if this.mustShow}}
      <DButton
        @action={{this.openDeletionModal}}
        class="btn-primary btn-warn"
        @label="legal_compliance.delete_uploads_button"
      />
    {{/if}}
  </template>
}
