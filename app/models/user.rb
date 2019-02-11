class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Statesman::Adapters::ActiveRecordQueries
  include SearchCop
  rolify

  INVITATION_REVOKED_STATUS = "revoked"
  INVITATION_PENDING_STATUS = "pending"
  INVITATION_ACCEPTED_STATUS = "accepted"

  INVITATION_STATUSES = [INVITATION_REVOKED_STATUS, INVITATION_PENDING_STATUS, INVITATION_ACCEPTED_STATUS]

  INVITATION_STATUSES_TEXT = {
    INVITATION_REVOKED_STATUS => "Revoked",
    INVITATION_PENDING_STATUS => "Pending",
    INVITATION_ACCEPTED_STATUS => "Accepted",
  }

  DISABLED_STATUS = "disabled"
  ENABLED_STATUS = "enabled"

  STATUSES = [DISABLED_STATUS, ENABLED_STATUS]

  STATUSES_TEXT = {
    DISABLED_STATUS => "Disabled",
    ENABLED_STATUS => "Enabled",
  }

  devise :two_factor_authenticatable,
         :invitable,
         :validatable,
         :jwt_authenticatable,
         :recoverable,
         otp_secret_encryption_key: ENV["OTP_SECRET_ENCRYPTION_KEY"],
         jwt_revocation_strategy: self,
         require_password_on_accepting: true,
         validate_on_invite: true

  search_scope :search_email do
    attributes :email
  end

  search_scope :search_name do
    attributes :first_name, :surname
  end

  scope :enabled, -> { where({disabled_by_user: nil, disabled_at: nil}) }
  scope :disabled, -> { where.not({disabled_by_user: nil, disabled_at: nil}) }

  before_invitation_created :enable_two_factor_auth

  has_and_belongs_to_many :work_venues, class_name: "Venue", :join_table => :users_venues
  belongs_to :invited_by, class_name: "User", :optional => true
  belongs_to :disabled_by_user, class_name: "User", optional: true
  has_many :history, class_name: "UsersHistory"

  validate :two_factor_code_match, if: :accepting_invitation
  validates_associated :roles
  validates :first_name, presence: true
  validates :surname, presence: true
  validates :email, presence: true
  validate :one_role
  validates :disabled_by_user, :disabled_at, :disabled_reason, presence: true, if: :any_of_disabled_present?
  validates :would_rehire, inclusion: {in: [true, false], message: "is required"}

  # validates :invitation_revoked_at, presence: true, if: :invitation_token.empty?

  attr_accessor :auth_code
  attr_reader :accepting_invitation, :raw_invitation_token

  # validation
  def one_role
    if roles.length != 1
      errors.add(:roles, "must have one role")
    end
  end

  def role
    roles.first.name
  end

  def full_name
    "#{first_name} #{surname}"
  end

  def disabled?
    disabled_by_user.present? && disabled_at.present?
  end

  def flagged?
    disabled? && would_rehire == false
  end

  def invitation_revoked?
    invitation_token.blank? && invitation_revoked_at.present?
  end

  def invitation_status
    if invitation_revoked?
      return INVITATION_REVOKED_STATUS
    end
    invited_to_sign_up? ? INVITATION_PENDING_STATUS : INVITATION_ACCEPTED_STATUS
  end

  def status
    disabled? ? DISABLED_STATUS : ENABLED_STATUS
  end

  def accept_invitation!
    @accepting_invitation = true
    super
  end

  def jwt_payload
    super.merge({"firstName" => first_name, "surname" => surname, "role" => role})
  end

  def two_factor_code_match
    if invited_to_sign_up? && created_by_invite?
      unless current_otp == auth_code
        errors.add(:auth_code, "doesn't match")
      end
    end
  end

  def any_of_disabled_present?
    disabled_at.present? || disabled_by_user.present? || disabled_reason.present?
  end

  def enable_two_factor_auth
    self.otp_required_for_login = true
    self.otp_secret = User.generate_otp_secret
  end
end
