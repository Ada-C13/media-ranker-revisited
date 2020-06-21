class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :require_login
  
  def render_404
    raise ActionController::RoutingError.new("Not Found")
  end

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def require_login
    if @login_user.nil?
        flash[:error] = "You must log in to do that"
      redirect_to root_path
    end
  end

end
