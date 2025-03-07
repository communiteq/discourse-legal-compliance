# plugins/legal-compliance/app/controllers/legal_compliance/delete_uploads_controller.rb

module LegalCompliance
  class DeleteUploadsController < ::ApplicationController
    requires_plugin 'legal-compliance'

    before_action :ensure_staff

    def index
      post = Post.find_by(id: params[:post_id])
      raise Discourse::NotFound unless post

      uploads = post.uploads.map do |upload|
        {
          id: upload.id,
          original_filename: upload.original_filename,
          sha1: upload.sha1,
          url: upload.url
        }
      end

      render json: { uploads: uploads }
    end

    def destroy
      post = Post.find_by(id: params[:post_id])
      raise Discourse::NotFound unless post

      upload_ids = params[:upload_ids].map(&:to_i)
      uploads_to_remove = post.uploads.where(id: upload_ids)

      uploads_to_remove.each do |upload|
        StaffActionLogger.new(current_user).log_custom("delete_upload", post_id: post.id, upload_id: upload.id)
        UploadReference.where(target: post, upload: upload).destroy_all
        upload.destroy
      end

      render json: { success: true, removed_uploads: uploads_to_remove.map(&:id) }
    end

  end
end

