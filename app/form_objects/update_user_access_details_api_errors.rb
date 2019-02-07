class UpdateUserAccessDetailsApiErrors
  def initialize(user:, role:)
    @user = user
    @role = role
  end
  attr_reader :user, :role

  def errors
    result = {}
    result[:base] = user.errors[:base] if user.errors[:base].present?
    if role.present?
      result[:role] = role.errors[:name] if role.errors[:name].present?
    end
    result[:venues] = user.errors[:work_venues] if user.errors[:work_venues].present?
    result
  end
end
