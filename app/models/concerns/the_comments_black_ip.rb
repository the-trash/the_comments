module TheCommentsBlackIp
  extend ActiveSupport::Concern
  
  included do
    validates :ip, presence:   true
    validates :ip, uniqueness: true
    scope :recent, -> { order('created_at DESC') }
  end
end