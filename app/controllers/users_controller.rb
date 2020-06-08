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
      user = User.create_user_from_github(auth_hash)
      if user.save 
        flash[:result_text] = "Logged in as new user #{user.username}"
      else
        flash[:messages] = "Could not log you in"
      end 
    end 

    session[:user_id] = user.id
    return redirect_to root_path
  end 

  
  def destroy 
    user = User.find_by(id: session[:user_id])
    name = user.username 
    session[:user_id] = nil
    flash[:result_text] = "Logged out, bye #{name}! :)"

    redirect_to root_path
  end 

end
