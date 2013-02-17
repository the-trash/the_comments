Rails.application.routes.draw do
  resources :comments do
    member do
      post   :to_spam
      delete :to_trash
    end
  end
end