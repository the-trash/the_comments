class User < ActiveRecord::Base
  include TheCommentsUser
  include TheCommentsCommentable
  authenticates_with_sorcery!

  has_many :posts

  # can be replaced to TheCommentsUser as default
  def comment_moderator? comment
    id == comment.holder_id
  end
end
