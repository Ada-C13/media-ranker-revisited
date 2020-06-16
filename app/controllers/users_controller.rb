class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def login
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: "github")

    if user
      # user was found in the database
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.username}"
    else
      
      # user not found in db, attempt to create a new user
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.username}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    # store logged in user in session
    session[:user_id] = user.id

    return redirect_to root_path
  end

def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
  end

end
