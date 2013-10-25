class UsersController < ApplicationController
  def autologin
    user = User.find params[:id]
    auto_login user if user
    redirect_to request.referrer || root_path
  end
end