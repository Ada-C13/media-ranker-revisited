class UsersController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    
    auth_hash = request.env["omniauth.auth"]
    
    user = User.find_by(uid: auth_hash[:uid], provider: params[:provider])
    if user
      flash[:success] = "Existing user #{user.username} is logged in."
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.username}"

      else
        flash[:error] = "could not create user account #{user.errors.messages}."
        redirect_to root_path
        return
      end
    end
    session[:user_id] = user.id
    redirect_to root_path
  end

  def logout
    if session[:user_id] != nil 
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
      redirect_to root_path
    else
      session[:user_id] = nil
      flash[:error] = "You must be logged in to log out!"
      redirect_to root_path
    end

  end
end
