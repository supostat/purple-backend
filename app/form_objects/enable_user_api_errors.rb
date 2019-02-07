class EnableUserApiErrors
  def initialize(user:)
    @user = user
  end
  attr_reader :user

  def errors
    result = {}
    result[:base] = user.errors[:base] if user.errors[:base].present?
    result
  end
end
