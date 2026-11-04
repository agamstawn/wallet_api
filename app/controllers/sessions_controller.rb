class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      new_session = user.sessions.create!
      render json: { token: new_session.token }, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    current_session.destroy
    head :no_content
  end
end
