class SendResetPasswordEmail
  Result = Struct.new(:success, :api_errors) do
    def success?
      success
    end
  end

  def initialize(email:)
    @email = email
  end

  def call
    user = User.find_or_initialize_by({email: email})

    if user.persisted?
      user.send_reset_password_instructions
    else
      if email.blank?
        user.errors.add(:email, :blank)
      end
      # do nothing
    end
    api_errors = nil
    success = user.errors.empty?
    unless success
      api_errors = SendResetPasswordEmailApiErrors.new(user: user)
    end
    Result.new(success, api_errors)
  end

  private

  attr_reader :email
end
