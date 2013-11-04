TheComments::Engine.routes.draw do
  resources :ip_black_lists do
    patch :to_state
  end

  resources :user_agent_black_lists do
    patch :to_state
  end

  resources :comments do
    member do
      post   :to_spam
      post   :to_draft
      post   :to_published
      delete :to_trash
    end

    collection do
      get :my
      get :incoming
      get :trash
    end
  end
end