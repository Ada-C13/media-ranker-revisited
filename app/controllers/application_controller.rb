class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :find_user # create order or set sho cart. If session

  # DPR: this will render a 404 page in production
  def render_404
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  def find_user
    if session[:user_id] # order_id
      @login_user = User.find_by(id: session[:user_id])
    end # else, create a new order order = order.new status pending save it id into session
  end
  
end
