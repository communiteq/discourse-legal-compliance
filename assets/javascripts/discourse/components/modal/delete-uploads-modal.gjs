import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, get } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import I18n from "discourse-i18n";
import { i18n } from "discourse-i18n";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { Input } from "@ember/component";

export default class DeleteUploadsModal extends Component {
  @service currentUser;
  @service dialog;
  @tracked uploads = [];
  @tracked selectedUploads = [];

  constructor() {
    super(...arguments);
    this.fetchUploads();
  }

  async fetchUploads() {
    try {
      const response = await ajax(`/legal_compliance/delete_uploads/${this.args.model.post.id}`);
      this.uploads = response.uploads.map(upload => ({
        ...upload,
        shortSha1: this.shortenSha1(upload.sha1),
        shortFilename: this.shortenFilename(upload.original_filename)
      }));
    } catch (error) {
      popupAjaxError(error);
    }
  }

  get modalTitle() {
    return I18n.t("legal_compliance.delete_uploads_modal.title");
  }

  @action
  deleteSelectedUploads() {
    const uploadIds = this.selectedUploads.map((upload) => upload.id);
    ajax({
      url: `/legal_compliance/delete_uploads/${this.args.model.post.id}`,
      type: "DELETE",
      data: {
        upload_ids: this.selectedUploads,
      },
    })
      .then(() => {
        this.args.closeModal();
        this.dialog.alert(i18n("legal_compliance.delete_uploads_modal.success"));
      })
      .catch((error) => {
        popupAjaxError(error);
      });
  }

  get hasNoSelectedUploads() {
    return this.selectedUploads.length === 0;
  }

  @action
  toggleUploadSelection(uploadId) {
    if (this.selectedUploads.includes(uploadId)) {
      this.selectedUploads = this.selectedUploads.filter(id => id !== uploadId);
    } else {
      this.selectedUploads = [...this.selectedUploads, uploadId];
    }
  }

  shortenSha1(sha1) {
    if (!sha1 || sha1.length < 9) {
      return sha1;
    }
    return `${sha1.slice(0, 6)}..${sha1.slice(-5)}`;
  }

  shortenFilename(filename) {
    if (!filename || filename.length <= 30) {
      return filename;
    }

    let lastDotIndex = filename.lastIndexOf(".");
    if (lastDotIndex === -1 || lastDotIndex < filename.length - 6) {
      // No extension, or extension very long (failsafe)
      return `${filename.slice(0, 27)}…`;
    }

    let extension = filename.slice(lastDotIndex);
    let basename = filename.slice(0, 27 - extension.length);

    return `${basename}…${extension}`;
  }


  <template>
    <DModal @title={{this.modalTitle}} @closeModal={{@closeModal}} class="delete-uploads-modal">
      <:body>
        {{#if this.uploads.length}}
          <table class="uploads-table">
            <thead>
              <tr>
                <th></th>
                <th>{{i18n "legal_compliance.delete_uploads_modal.table.filename"}}</th>
                <th>{{i18n "legal_compliance.delete_uploads_modal.table.sha1"}}</th>
                <th>{{i18n "legal_compliance.delete_uploads_modal.table.url"}}</th>
              </tr>
            </thead>
            <tbody>
              {{#each this.uploads as |upload|}}
                <tr>
                  <td>
                    <Input
                      @type="checkbox"
                      @checked={{this.selectedUploads.has upload.id}}
                      {{on "change" (fn this.toggleUploadSelection upload.id)}}
                    />
                  </td>
                  <td class="pre">{{upload.shortFilename}}</td>
                  <td class="pre">{{upload.shortSha1}}</td>
                  <td><a href="{{upload.url}}" target="_blank">{{i18n "legal_compliance.delete_uploads_modal.table.view"}}</a></td>
                </tr>
              {{/each}}
            </tbody>
          </table>
      {{/if}}
      </:body>
      <:footer>
        <DButton
          @action={{action "deleteSelectedUploads"}}
          class="btn-primary btn-warn"
          @label="legal_compliance.delete_uploads_modal.confirm_button.label"
          @disabled={{this.hasNoSelectedUploads}}
        />
        <DButton
          @action={{@closeModal}}
          class="btn-primary btn-danger"
          @label="legal_compliance.delete_uploads_modal.cancel_button.label"
        />
      </:footer>
    </DModal>
  </template>
}

