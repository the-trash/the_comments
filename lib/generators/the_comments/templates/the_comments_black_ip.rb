module TheCommentsBlackIp
  extend ActiveSupport::Concern
  
  included do
    # attr_accessible :ip, :state    
    validates :ip, presence:   true
    validates :ip, uniqueness: true
  end
end