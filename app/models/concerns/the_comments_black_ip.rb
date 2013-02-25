module TheCommentsBlackIp
  extend ActiveSupport::Concern
  
  included do
    attr_accessible :ip

    validates :ip, presence:   true
    validates :ip, uniqueness: true
  end
end