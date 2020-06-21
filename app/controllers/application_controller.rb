class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def render_404
    raise ActionController::RoutingError.new("Not Found")
  end

  

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
    return @login_user
  end


  def require_login
    user = find_user()
    if user.nil?
        flash[:error] = "You must log in to do that"
      redirect_to root_path
    end
  end

end
