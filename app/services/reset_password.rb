class ResetPassword
  Result = Struct.new(:success, :user, :api_errors) do
    def success?
      success
    end
  end

  def call(params:)
    token = params.fetch(:token)
    password = params.fetch(:password)
    password_confirmation = params.fetch(:password_confirmation)

    reset_password_token = Devise.token_generator.digest(nil, :reset_password_token, token)
    user = User.find_or_initialize_with_errors([:reset_password_token], {reset_password_token: reset_password_token})
    success = false

    if user.persisted?
      if user.reset_password_period_valid?
        success = user.reset_password(password, password_confirmation)
      else
        user.errors.add(:base, "Token has expired, please request a new one")
      end
    else
      user.errors.add(:base, "Token is invalid")
    end
    api_errors = nil
    unless success
      api_errors = ResetPasswordApiErrors.new(user: user)
    end
    Result.new(success, user, api_errors)
  end
end
