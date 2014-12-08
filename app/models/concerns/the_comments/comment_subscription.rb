module TheComments
  module CommentSubscription

    extend ActiveSupport::Concern

    included do
      has_one :user
      has_one :comment
    end
  end
end
