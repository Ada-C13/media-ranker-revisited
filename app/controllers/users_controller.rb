class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid])
    
    if user #user exists
      flash[:notice] = "Existing user #{user.username} is looged in."
    else #user doesn't exist yet - new user
      user = User.build_from_github(auth_hash)
      if user.save 
        flash[:success] = "logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create user account #{user.error.messages}"
        return 
        redirect_to root_path
      end
    end 

    session[:user_id] = user.id
    redirect_to root_path
  end
end
