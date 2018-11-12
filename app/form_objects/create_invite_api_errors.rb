class CreateInviteApiErrors
  def initialize(user:, role:)
    @user = user
    @role = role
  end
  attr_reader :user, :role

  def errors
    result = {}
    result[:firstName] = user.errors[:first_name] if user.errors[:first_name].present?
    result[:surname] = user.errors[:surname] if user.errors[:surname].present?
    result[:email] = user.errors[:email] if user.errors[:email].present?
    result[:venuesIds] = user.errors[:work_venues] if user.errors[:work_venues].present?
    if role.present?
      result[:role] = role.errors[:name] if role.errors[:name].present?
    end
    result
  end
end
