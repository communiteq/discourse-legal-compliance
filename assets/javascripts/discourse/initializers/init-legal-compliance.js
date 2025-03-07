import { withPluginApi } from "discourse/lib/plugin-api";
import DeleteUploadsModal from "../components/modal/delete-uploads-modal";

export default {
  name: "legal-compliance",

  initialize(container) {
    withPluginApi("1.2.0", (api) => {
      const currentUser = api.getCurrentUser();

      api.addPostAdminMenuButton((attrs) => {
        return {
          icon: "trash-can",
          label: "legal_compliance.delete_uploads_button",
          action: (post) => {
            const modal = container.lookup("service:modal");
            modal.show(DeleteUploadsModal, {
              model: {
                post: post,
              }
            });
          },
          secondaryAction: "closeAdminMenu",
          className: "delete-uploads",
        };
      });

    });
  }
}

