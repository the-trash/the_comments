class UserAgentBlackListsController < ApplicationController
  # Define your restrict methods and use them like this:
  # 
  # before_action :user_required
  # before_action :admin_required
  # 
  # Only Admin should have an access to following methods
  # Methods: [:index, :to_state]
  include TheCommentsUserAgentController
end