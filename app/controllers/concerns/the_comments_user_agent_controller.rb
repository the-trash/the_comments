module TheCommentsUserAgentController
  # extend ActiveSupport::Concern
  # included do; end
  def index
    @ip_black_lists = if params[:ip]
      UserAgentBlackList.where(ip: params[:ip])
    else
      UserAgentBlackList.order('count DESC').page(params[:page])
    end
  end

  def to_state
    return render text: UserAgentBlackList.where(id: params[:user_agent_black_list_id]).first.update!(state: params[:state])
  end
end