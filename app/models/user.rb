class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Statesman::Adapters::ActiveRecordQueries
  include SearchCop

  INVITATION_REVOKED_STATUS = "revoked"
  INVITATION_PENDING_STATUS = "pending"
  INVITATION_ACCEPTED_STATUS = "accepted"

  INVITATION_STATUSES = [INVITATION_REVOKED_STATUS, INVITATION_PENDING_STATUS, INVITATION_ACCEPTED_STATUS]

  INVITATION_STATUSES_TEXT = {
    INVITATION_REVOKED_STATUS => "Revoked",
    INVITATION_PENDING_STATUS => "Pending",
    INVITATION_ACCEPTED_STATUS => "Accepted",
  }

  rolify

  devise :two_factor_authenticatable,
         :invitable,
         :validatable,
         :jwt_authenticatable,
         otp_secret_encryption_key: ENV["OTP_SECRET_ENCRYPTION_KEY"],
         jwt_revocation_strategy: self,
         require_password_on_accepting: true,
         validate_on_invite: true

  search_scope :search_email do
    attributes :email
  end

  before_invitation_created :enable_two_factor_auth

  has_and_belongs_to_many :work_venues, class_name: "Venue", :join_table => :users_venues
  has_many :user_transitions, autosave: false
  belongs_to :invited_by, class_name: "User"
  validate :two_factor_code_match, if: :accepting_invitation
  validates_associated :roles
  validates :first_name, presence: true
  validates :surname, presence: true
  validates :email, presence: true
  # validates :invitation_revoked_at, presence: true, if: :invitation_token.empty?

  attr_accessor :auth_code
  attr_reader :accepting_invitation

  def full_name
    "#{first_name} #{surname}"
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

  def accept_invitation!
    @accepting_invitation = true
    super
  end

  def jwt_payload
    super.merge({"firstName" => first_name, "surname" => surname})
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

  def state_machine
    @state_machine ||= UserStateMachine.new(self, transition_class: UserTransition)
  end

  def self.transition_class
    UserTransition
  end

  def self.initial_state
    :enabled
  end

  private_class_method :initial_state

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine
end
