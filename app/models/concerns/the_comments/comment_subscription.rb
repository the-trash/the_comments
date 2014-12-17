module TheComments
  module CommentSubscription

    module Relations
      extend ActiveSupport::Concern

      included do
        has_many :comment_subscriptions

        has_many :active_subscriptions,
          -> { where(state: :active) },
          class_name: :CommentSubscription
      end
    end

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

      included { include ::TheComments::CommentSubscription::Relations }

      def add_subscriber(current_user)
        return unless subscribe_to_thread_flag
        comment = self

        if current_user
          comment.comment_subscriptions.create(user_id: current_user.id)
        else
          _email = ::TheComments.normalize_email(contacts)
          if _email.match ::TheComments::EMAIL_REGEXP
            comment.comment_subscriptions.create(email: _email)
          end
        end
      end

      def send_notifications_to_subscribers
        comment = self

        subscribers_emails.each do |email|
          if ::TheComments.config.async_processing
            TheCommentsNotificationsWorker.perform_async(email, comment.id)
          else
            CommentSubscriberMailer.notificate(email, comment).deliver
          end
        end
      end

      private

      def subscribers_emails
        comment = self
        parents = comment.ancestors.includes(:comment_subscriptions)

        subscriptions = parents.map(&:active_subscriptions).compact.flatten
        users = ::User.where(id: subscriptions.map(&:user_id).compact)

        u_emails = users.map(&:email).compact
        g_emails = subscriptions.map(&:email).compact

        (u_emails | g_emails).uniq
      end
    end # module Comment
  end
end
