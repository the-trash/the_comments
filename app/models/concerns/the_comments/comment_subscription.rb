module TheComments
  module CommentSubscription

    module User
      extend ActiveSupport::Concern

      included do
        belongs_to :user
        belongs_to :comment

        validates :user_id, uniqueness: { scope: :comment_id }, if: ->(c) { c.email.blank? }
        validates :email,   uniqueness: { scope: :comment_id }, if: ->(c) { c.user.blank?  }
      end
    end # module User

    module Comment
      extend ActiveSupport::Concern

      included do
        has_many :comment_subscriptions
      end

      def add_subscriber(current_user)
        return unless subscribe_to_thread_flag

        if current_user
          self.comment_subscriptions.create(user: current_user)
        else
          _email = normalize_email(contacts)
          if _email.match ::TheComments::EMAIL_REGEXP
            self.comment_subscriptions.create(email: _email)
          end
        end
      end
    end # module Comment
  end
end
