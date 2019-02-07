class UpdateUserPersonalDetailsApiErrors
  def initialize(user:)
    @user = user
  end
  attr_reader :user

  def errors
    result = {}
    result[:base] = user.errors[:base] if user.errors[:base].present?
    result[:firstName] = user.errors[:first_name] if user.errors[:first_name].present?
    result[:surname] = user.errors[:surname] if user.errors[:surname].present?
    result[:email] = user.errors[:email] if user.errors[:email].present?
    result
  end
end
