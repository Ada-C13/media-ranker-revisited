class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end


  def current_user 
    @login_user ||= session[:merchant_id] &&
    Merchant.find_by(id: session[:merchant_id])
  end

  def require_login
    unless current_user
      redirect_to root_path
      flash[:danger] = "Must be logged in as a user."
      return
    end
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
