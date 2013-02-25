Rails.application.routes.draw do
  resources :comments do
    member do
      post   :to_spam
      post   :to_draft
      post   :to_published
      delete :to_trash
    end
  end
end