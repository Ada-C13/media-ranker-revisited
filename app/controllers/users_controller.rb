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
      flash[:success] = "Welcome back, #{user.username}"
    else
      user = User.create_user_from_github(auth_hash)
      if user.save 
        flash[:success] = "Welcome, #{user.username}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end 
    end 
    session[:user_id] = user.id
    return redirect_to root_path

  end 


  def destroy 
    user = User.find_by(id: session[:user_id])
    name = user.username 
    session[:user_id] = nil
    flash[:success] = "Logged out, bye #{name}! :)"

    redirect_to root_path
  end 
end
