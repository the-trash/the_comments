module TheCommentsBlackUserAgent
  extend ActiveSupport::Concern

  included do
    validates :user_agent, presence:   true
    validates :user_agent, uniqueness: true
  end  
end