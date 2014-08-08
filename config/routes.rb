module TheComments
  class UserRoutes
    def call mapper, options = {}
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

  class AdminRoutes
    def call mapper, options = {}
      mapper.collection do
        mapper.get :total_draft
        mapper.get :total_published
        mapper.get :total_deleted
        mapper.get :total_spam
      end
    end
  end
end
