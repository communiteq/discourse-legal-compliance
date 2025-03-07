# frozen_string_literal: true

module ::LegalCompliance
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace LegalCompliance
  end
end
