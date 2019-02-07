class CreateInviteApiErrors
  def initialize(invited_user:)
    @invited_user = invited_user
  end
  attr_reader :invited_user

  def errors
    result = {}
    result[:firstName] = invited_user.errors[:first_name] if invited_user.errors[:first_name].present?
    result[:surname] = invited_user.errors[:surname] if invited_user.errors[:surname].present?
    result[:email] = invited_user.errors[:email] if invited_user.errors[:email].present?
    result[:venuesIds] = invited_user.errors[:work_venues] if invited_user.errors[:work_venues].present?
    result[:role] = invited_user.errors[:roles] if invited_user.errors[:roles].present?
    result
  end
end
