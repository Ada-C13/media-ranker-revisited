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
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.new(
        uid: auth_hash[:uid], 
        provider: auth_hash[:provider], 
        username: auth_hash[:info][:nickname], 
        name: auth_hash[:info][:name], 
        email: auth_hash[:info][:email]
      )
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
    return
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
