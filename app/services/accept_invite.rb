class AcceptInvite
  def initialize(user:)
    @user = user
  end

  def call(params:)
    auth_code = params.fetch(:authCode)
    password = params.fetch(:password)
    password_confirmation = params.fetch(:passwordConfirmation)
    user = User.accept_invitation!(invitation_token: params[:invitationToken], password: password, password_confirmation: password_confirmation, auth_code: auth_code)
    unless user.errors.empty?
      raise ActiveRecord::RecordInvalid.new(user)
    end
    user
  end

  private

  attr_reader :user
end
