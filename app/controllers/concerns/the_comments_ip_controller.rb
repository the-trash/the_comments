module TheCommentsIpController
  extend ActiveSupport::Concern

  included do
    def index
      @ip_black_lists = if params[:ip]
        IpBlackList.where(ip: params[:ip])
      else
        IpBlackList.order('count DESC').page(params[:page])
      end
    end

    def to_state
      return render text: IpBlackList.where(id: params[:ip_black_list_id]).first.update!(state: params[:state])
    end
  end
end