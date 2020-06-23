class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user 

  def render_404
    raise ActionController::RoutingError.new("Not Found")
  end


  private

  def find_user
    if session[:uid]
      @login_user = User.find_by(uid: session[:uid])
    end
  end
end
