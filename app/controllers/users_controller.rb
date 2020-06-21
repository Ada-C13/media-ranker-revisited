class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: params[:provider])
    
    if user
      flash[:status] = :success
      flash[:result_text] = "Logged in as existing user #{user.username}."
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.username}."
      else
        flash[:status] = :error
        flash[:result_text] = "Could not create user account."
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
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
end
