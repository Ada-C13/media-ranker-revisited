class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def current_user
    return @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    puts "REQUIRE LOGIN"
    if current_user.nil?
      flash[:status] = :failure 
      flash[:result_text] = "You must be logged in to do that"

      redirect_to root_path
    end
  end

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
