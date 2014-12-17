module TheComments
  # TheComments::UserRoutes.mixin(self)
  # TheComments::AdminRoutes.mixin(self)
  # TheComments::SubscriptionRoutes.mixin(self)

  class UserRoutes
    def self.mixin mapper
      mapper.resources :comments, only: [:create] do
        mapper.collection do
          mapper.get :manage
          mapper.get :my_comments

          mapper.get :my_draft
          mapper.get :my_published
          mapper.get :my_deleted
          mapper.get :my_spam

          mapper.get :draft
          mapper.get :published
          mapper.get :deleted
          mapper.get :spam
        end

        mapper.member do
          mapper.post   :to_spam
          mapper.post   :to_draft
          mapper.post   :to_published
          mapper.delete :to_deleted
        end
      end
    end
  end

  class AdminRoutes
    def self.mixin mapper
      mapper.resources :comments, only: [] do
        mapper.collection do
          mapper.get :total_draft
          mapper.get :total_published
          mapper.get :total_deleted
          mapper.get :total_spam
        end
      end
    end
  end

  class SubscriptionRoutes
    def self.mixin mapper
      mapper.get "/unsubscribe_comment/:type/:comment_id/:id"     => "comment_subscriptions#unsubscribe_comment",     as: :unsubscribe_comment
      mapper.get "/unsubscribe_commentable/:type/:comment_id/:id" => "comment_subscriptions#unsubscribe_commentable", as: :unsubscribe_commentable
      mapper.get "/unsubscribe_all/:type/:id"                     => "comment_subscriptions#unsubscribe_all",         as: :unsubscribe_all
    end
  end
end
