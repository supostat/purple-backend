class CreateInviteApiErrors
  def initialize(invited_user:, role:)
    @invited_user = invited_user
    @role = role
  end
  attr_reader :invited_user, :role

  def errors
    result = {}
    result[:firstName] = invited_user.errors[:first_name] if invited_user.errors[:first_name].present?
    result[:surname] = invited_user.errors[:surname] if invited_user.errors[:surname].present?
    result[:email] = invited_user.errors[:email] if invited_user.errors[:email].present?
    result[:venuesIds] = invited_user.errors[:work_venues] if invited_user.errors[:work_venues].present?
    if role.present?
      result[:role] = role.errors[:name] if role.errors[:name].present?
    end
    result
  end
end
