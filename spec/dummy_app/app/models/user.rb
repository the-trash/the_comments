class User < ActiveRecord::Base
  include TheComments::User
  include TheComments::Commentable

  authenticates_with_sorcery!

  has_many :posts

  # can be replaced to TheCommentsUser as default
  def admin?
    self == User.first
  end

  def comments_admin?
    admin?
  end

  def comments_moderator? comment
    id == comment.holder_id
  end
end
