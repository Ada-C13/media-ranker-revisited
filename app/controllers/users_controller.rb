class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create 
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user 
      flash[:result_text] = "Logged in as returning user #{user.username}"
    else
      if user
      
    end 

  end 

  
  def destroy 
    user = User.find_by(id: session[:user_id])
    name = user.username 
    session[:user_id] = nil
    flash[:status] = "Logged out, bye #{name}! :)"
  end 

end
