# frozen_string_literal: true

# name: discourse-legal-compliance
# about: Provides functions needed to be GDPR/CCPA/DMCA/OSA
# version: 1.0.3
# authors: Communiteq
# url: https://github.com/communiteq/discourse-legal-compliance

enabled_site_setting :discourse_legal_compliance_enabled

module ::LegalCompliance
  PLUGIN_NAME = "discourse-legal-compliance"
end

register_asset "stylesheets/legal_compliance.scss"
require_relative "lib/legal_compliance/engine"

after_initialize do

  register_search_advanced_filter(/upload:(.+)$/) do |posts, match|
    sha1_match = match.scan(/[a-fA-F0-9]{40}/)
    if sha1_match.present?
      upload = Upload.find_by(sha1: sha1_match.first)
    else
      base62_match = match.scan(/[a-zA-Z0-9]{20,30}/)
      if base62_match.present?
        sha1 = Upload.sha1_from_base62_encoded(base62_match.first)
        upload = Upload.find_by(sha1: sha1)
      end
    end

    if upload
      post_ids = upload.posts.pluck(:id)
      posts.where("posts.id IN (?)", post_ids)
    else
      posts
    end
  end
end

