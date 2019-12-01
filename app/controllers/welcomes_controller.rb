class WelcomesController < ApplicationController
  before_action :verify_and_authenticate_user
  def index
    render json: {msg: "invalid token"} unless token_valid?
  end

  private

  def token_valid?
    user = User.find_by(token: params[:token])
    user ? true : false
  end
end