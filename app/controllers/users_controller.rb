class UsersController < ApplicationController
  before_action :require_login, only: [:logout]

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
      flash[:success] = "Logged in as returning user #{user.username}"
    else 
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create new user account."
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def logout 
    if session[:user_id].nil?
      flash[:error] = "Can't log out"
      return redirect_to root_path
    else 
      session[:user_id] = nil
      flash[:success] = "Successfully logged out!"
      redirect_to root_path
    end
  end
end
