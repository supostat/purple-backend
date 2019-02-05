class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordInvalid, with: :render_server_error_response

  rescue_from CanCan::AccessDenied do |exception|
    head :forbidden, content_type: 'application/json'
  end

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: "400",
          title: "Bad Request",
          detail: resource.errors,
          code: "100",
        },
      ],
    }, status: :bad_request
  end

  def render_server_error_response(exception)
    render json: {}, status: :internal_server_error
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:password, :password_confirmation, :auth_code])
  end
end
