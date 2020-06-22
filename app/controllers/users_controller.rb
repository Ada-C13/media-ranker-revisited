class UsersController < ApplicationController

  skip_before_action :require_login, only:[:create]
  before_action :find_user, except: [:index, :create]

  def index
    @users = User.all
  end

  def show
    render_404 unless @login_user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    @user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if @user
      session[:user_id] = @user.uid
      flash[:success] = "Logged in as returning user #{@user.username}"
      redirect_to root_path
      return
    else
      @user = User.build_from_github(auth_hash)
      if @user.save
        session[:username] = @user.username
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{@user.username} with ID #{user.uid}"
        redirect_to root_path
        return
      else
        flash[:status] = :failure
        flash[:result_text] = "Could not log in"
        flash[:messages] = @user.errors.messages
        redirect_to root_path
        return
      end
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
