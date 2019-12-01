class UsersController < ApplicationController
  def create
    @user = User.new(user_signup_params)
    respond_to do |format|
      format.js do
        if @user.save
          @msg = "Successfully registered"  
        else
          @msg = "Registration failed"
        end
      end
    end
  end
 

  def signup
    @user = User.new
  end

  def signin
    @user = User.new
  end

  def signinpost
    @signin_info = User.verify_and_authenticate(user_signin_params)
  end

  def signout
    @user = User.find_by_token(params[:user_token])
    if @user
      if @user.update_attributes(token: "")
        render json: {msg: "Successfully Logged out",redirect_url: "/users/signin"}.to_json
      else
        render json: {msg: "Logout Unsuccessfull",redirect_url: "/"}.to_json
      end  
    else
      render json: {msg: "Logout Unsuccessfull",redirect_url: "/"}.to_json
    end
  end

  def user_search
    final_response = {
      tracks: [],
      similar_artists: [],
      msg: [],
      search_logs: []  
    }
    auth_token = params[:user_token]
    @user = User.find_by(token: auth_token)
    artist_name = params[:artist_name]
    if @user
      final_response = LastfmService.new(artist_name: artist_name,user: @user).artist_tracks_and_similar_artists(final_response)
      render json: final_response.to_json
    else
      final_response[:msg] = "The User token is invalid"
      render json: final_response.to_json
    end
  end

  private 
  def user_signup_params
    params.require(:user).permit(:password,:password_confirmation,:username)
  end

  def user_signin_params
    params.require(:user).permit(:password,:username)
  end

end
