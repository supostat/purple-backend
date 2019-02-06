class AcceptInvite
  Result = Struct.new(:success, :user, :api_errors) do
    def success?
      success
    end
  end

  def call(params:)
    auth_code = params.fetch(:auth_code)
    password = params.fetch(:password)
    password_confirmation = params.fetch(:password_confirmation)
    invitation_token = params.fetch(:invitation_token)

    user = User.accept_invitation!(invitation_token: invitation_token, password: password, password_confirmation: password_confirmation, auth_code: auth_code)
    result = user.errors.empty?

    api_errors = nil
    if !result
      api_errors = AcceptInviteApiErrors.new(user: user)
    end

    Result.new(result, user, api_errors)
  end
end
