Rails.application.routes.draw do
  resources :comments do
    collection do
      get :my
      get :incoming
    end

    member do
      post   :to_spam
      post   :to_draft
      post   :to_published
      delete :to_trash
    end
  end
end