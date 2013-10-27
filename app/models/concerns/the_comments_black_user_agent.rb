module TheCommentsBlackUserAgent
  extend ActiveSupport::Concern

  included do
    validates :user_agent, presence:   true
    validates :user_agent, uniqueness: true
    scope :recent, -> { order('created_at DESC') }
  end  
end