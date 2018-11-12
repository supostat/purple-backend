class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  rolify

  devise :two_factor_authenticatable,
         :invitable,
         :validatable,
         :jwt_authenticatable,
         otp_secret_encryption_key: ENV["OTP_SECRET_ENCRYPTION_KEY"],
         jwt_revocation_strategy: self,
         require_password_on_accepting: true

  before_invitation_created :enable_two_factor_auth
  validate :two_factor_code_match, if: :accepting_invitation

  validates_associated :roles
  has_and_belongs_to_many :work_venues, class_name: 'Venue', :join_table => :users_venues

  validates :email, presence: true

  attr_accessor :auth_code
  attr_reader :accepting_invitation

  def accept_invitation!
    @accepting_invitation = true
    super
  end

  def jwt_payload
    super.merge({ 'firstName' => first_name, 'surname' => surname })
  end

  def two_factor_code_match
    if invited_to_sign_up? && created_by_invite?
      unless current_otp == auth_code
        errors.add(:auth_code, "doesn't match")
      end
    end
  end

  def enable_two_factor_auth
    self.otp_required_for_login = true
    self.otp_secret = User.generate_otp_secret
  end
end
