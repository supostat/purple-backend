class DisableUserApiErrors
  def initialize(user:)
    @user = user
  end
  attr_reader :user

  def errors
    result = {}
    result[:base] = user.errors[:base] if user.errors[:base].present?
    result[:disabledByUser] = user.errors[:disabled_by_user] if user.errors[:disabled_by_user].present?
    result[:disabledReason] = user.errors[:disabled_reason] if user.errors[:disabled_reason].present?
    result[:neverRehire] = user.errors[:never_rehire] if user.errors[:never_rehire].present?
    result
  end
end
