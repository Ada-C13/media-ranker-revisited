class UsersController < ApplicationController

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid],
                        provider: auth_hash[:provider])
    
    if user 
      flash[:status] = :success
      flash[:result_text] = "Existing user #{user.username} is logged in"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.username}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Couldn't create user account"
        flash.now[:messages] = user.errors.messages
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
  
  def logout
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      unless user.nil?
        session[:user_id] = nil
        flash[:status] = :success
        flash[:result_text] = "Successfully logged out"
      else
        flash[:status] = :failure
        flash[:result_text] = 'Error unknown user'
        session[:user_id] = nil
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in before to logout!"
    end
    redirect_to root_path
  end
end