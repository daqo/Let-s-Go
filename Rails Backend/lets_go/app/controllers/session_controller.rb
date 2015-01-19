class SessionController < ApplicationController
  def create
    user = User.find_by("username = ? OR email = ?", params[:username_or_email], params[:username_or_email])
    if user && user.authenticate(params[:password])
      render json: user.session_api_key, status: 201
    else
      render json: {}, status: 401
    end
  end
end
