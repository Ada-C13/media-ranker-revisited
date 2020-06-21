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

    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      # User was found in the database
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    session[:username] = user.username
    return redirect_to root_path
  end

  def destroy
    if session[:user_id]
      session[:user_id] = nil
      flash[:success] = "Successfully logged out!"
      redirect_to root_path
      return
    else
      flash[:failure] = "You are not logged on"
      redirect_to root_path
      return
    end
  end
end
