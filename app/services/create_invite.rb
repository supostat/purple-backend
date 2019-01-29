class CreateInvite
  Result = Struct.new(:success, :invited_user, :role, :api_errors) do
    def success?
      success
    end
  end

  def initialize(inviter: nil)
    @inviter = inviter
  end

  def call(params:)
    invited_user = nil
    success = false
    api_errors = nil
    email = params.fetch(:email)
    first_name = params.fetch(:firstName)
    surname = params.fetch(:surname)
    role = params.fetch(:role)
    venues_ids = params.fetch(:venues)
    venues = Venue.where(id: venues_ids)

    ActiveRecord::Base.transaction do
      invited_user = User.invite!({email: email, first_name: first_name, surname: surname, work_venues: venues}, inviter) do |u|
        u.skip_invitation = true
      end
      role = invited_user.add_role(role)
      success = invited_user.errors.empty? && role.errors.empty?
      raise ActiveRecord::Rollback unless success
      invited_user.deliver_invitation
    end

    unless success == true
      api_errors = CreateInviteApiErrors.new(invited_user: invited_user, role: role)
    end

    Result.new(success, invited_user, role, api_errors)
  end

  private

  attr_reader :inviter
end
