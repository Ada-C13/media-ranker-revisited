class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login
  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end
  
  def current_user
    return User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def require_login
    if current_user.nil?
      flash[:error] = "Oops. Looks like you don't have permission to view this page. Please login or create an account."
      redirect_to root_path
    end
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
