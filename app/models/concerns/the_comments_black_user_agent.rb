module TheCommentsBlackUserAgent
  extend ActiveSupport::Concern

  included do
    attr_accessible :ip, :state

    validates :user_agent, presence:   true
    validates :user_agent, uniqueness: true
  end  
end