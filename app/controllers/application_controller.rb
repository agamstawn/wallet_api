class ApplicationController < ActionController::API
  before_action :authenticate!

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.message }, status: :not_found
  end
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end

  attr_reader :current_session

  def current_user
    current_session&.user
  end

  private

  def authenticate!
    token = request.headers["Authorization"].to_s[/\ABearer (.+)\z/, 1]
    @current_session = Session.find_by(token: token) if token.present?
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_session
  end
end
