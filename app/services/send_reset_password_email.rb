class SendResetPasswordEmail
  def initialize(email:)
    @email = email
  end

  def call
    user = User.find_by(email: email)
    if user.present?
      a = user.send_reset_password_instructions
    else
      # do nothing
    end
  end

  private

  attr_reader :email
end