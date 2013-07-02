module TheCommentsBlackIp
  extend ActiveSupport::Concern
  
  included do
    validates :ip, presence:   true
    validates :ip, uniqueness: true
  end
end