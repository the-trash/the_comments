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
        has_one :comment_subscription

        has_one :active_subscription,
          -> { where(state: :active) },
          class_name: :CommentSubscription
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

      def send_notifications_to_subscribers
        emails = subscribers_emails
        binding.pry
      end

      private

      def subscribers_emails
        parents = self.ancestors.includes(:comment_subscription)

        subscriptions = parents.map(&:active_subscription).compact
        users = ::User.where(id: subscriptions.map(&:user_id).compact)

        u_emails = users.map(&:email).compact
        g_emails = subscriptions.map(&:email).compact

        (u_emails | g_emails).uniq
      end
    end # module Comment
  end
end
