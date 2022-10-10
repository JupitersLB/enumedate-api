class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :check_token_exists
  attr_reader :current_token

  rescue_from Token::AccessDenied, with: :render_error_response
  rescue_from ActionController::ParameterMissing, with: :render_missing_param_error
  rescue_from EnumedateApiError, 
              with: :render_error_response


  private

  def check_token_exists
    authenticate_or_request_with_http_token do |token, _options|
      @current_token = Token.find_by(value: token) || Token.from_firebase_jwt(token)
      raise Token::AccessDenied unless @current_token
      @current_token

    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      raise Token::AccessDenied
    end
    if @current_token.user && @current_token.user.disabled?
      raise UserDisabled, 'User disabled'
    end


  end

  def render_missing_param_error(exception)
    render json: { message: exception.message }, status: 400
  end

  def render_error_response(exception)
    render json: { message: exception.message, code: exception.code }, status: exception.http_status
  end
end
