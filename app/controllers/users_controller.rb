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
      flash[:success] = "Logged in as returning user #{user.name}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.name}"
      else
       
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        
      end
    end
    session[:uid] = user.uid
    redirect_to root_path
    return
  end

  def destroy
    session[:uid] = nil
    flash[:success] = "Successfully logged out!"

    redirect_to root_path
  end
end