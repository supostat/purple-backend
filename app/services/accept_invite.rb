class AcceptInvite
  def initialize(user:)
    @user = user
  end

  def call(params:)
    auth_code = params.fetch(:auth_code)
    password = params.fetch(:password)
    password_confirmation = params.fetch(:password_confirmation)
    invitation_token = params.fetch(:invitation_token)
    user = User.accept_invitation!(invitation_token: invitation_token, password: password, password_confirmation: password_confirmation, auth_code: auth_code)
    unless user.errors.empty?
      raise ActiveRecord::RecordInvalid.new(user)
    end
    user
  end

  private

  attr_reader :user
end
