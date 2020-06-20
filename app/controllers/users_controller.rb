class UsersController < ApplicationController
  skip_before_action :require_login

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])

    if user
      
      flash[:success] = "Welcome back, #{user.username}!"
    else
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Welcome to Media Ranker, #{user.username}!"
      else
        flash[:error] = "User account could not be created: #{user.errors.messages}"
        redirect_to root_path
        return
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
  end

  def login_form
  end

  def login
    username = params[:username]
    if username and user = User.find_by(username: username)
      session[:user_id] = user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.new(username: username)
      if user.save
        session[:user_id] = user.id
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
    redirect_to root_path
  end

  def logout
    if !session[:user_id].nil?
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
      redirect_to root_path
    else
      flash[:status] = :unauthorized
      flash[:error] = "No user logged in."
      redirect_to root_path
    end
  end
end
