Rails.application.routes.draw do
  concern :the_comments do
    member do
      post   :to_spam
      post   :to_draft
      post   :to_published
      delete :to_deleted
    end

    collection do
      get :manage

      get :my_draft
      get :my_published
      get :my_comments

      get :total_draft
      get :total_published
      get :total_deleted
      get :total_spam

      get :draft
      get :published
      get :deleted
      get :spam
    end
  end

  # resources :comments, concerns: :the_comments
end