LegalCompliance::Engine.routes.draw do
  get '/delete_uploads/:post_id' => 'delete_uploads#index'
  delete '/delete_uploads/:post_id' => 'delete_uploads#destroy'
end

Discourse::Application.routes.draw do
  mount ::LegalCompliance::Engine, at: "/legal_compliance"
end

