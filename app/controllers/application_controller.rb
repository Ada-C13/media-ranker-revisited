class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  def require_login
    if current_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to do that"
      redirect_to root_path
    end
  end
  
  def current_user
    @current_user = User.find_by(id: session[:user_id])
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
