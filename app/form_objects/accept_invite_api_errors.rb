class AcceptInviteApiErrors
  def initialize(user:)
    @user = user
  end
  attr_reader :user

  def errors
    result = {}
    result[:base] = user.errors[:base] if user.errors[:base].present?
    result[:password] = user.errors[:password] if user.errors[:password].present?
    result[:passwordConfirmation] = user.errors[:password_confirmation] if user.errors[:password_confirmation].present?
    result[:invitationToken] = user.errors[:invitation_token] if user.errors[:invitation_token].present?
    result
  end
end
