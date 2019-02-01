class Api::V1::PasswordsController < ApplicationController
  def index
    render json: {ok: 'ok'}, status: 200
  end

  def send_reset_password_email
    result = SendResetPasswordEmail.new(email: email_from_params).call
    if result.success?
      render json: {}, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  def reset_password
    result = ResetPassword.new.call(params: reset_password_params)

    if result.success?
      render json: {}, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  private

  def email_from_params
    params.fetch(:email)
  end

  def reset_password_params
    {
      token: params.fetch(:token),
      password: params.fetch(:password),
      password_confirmation: params.fetch(:passwordConfirmation)
    }
  end
end
