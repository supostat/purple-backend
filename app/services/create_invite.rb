class CreateInvite
  Result = Struct.new(:success, :user, :role, :api_errors) do
    def success?
      success
    end
  end

  def initialize(inviter: nil)
    @inviter = inviter
  end

  def call(params:)
    email = params.fetch(:email)
    first_name = params.fetch(:firstName)
    surname = params.fetch(:surname)
    role = params.fetch(:role)
    venues_ids = params.fetch(:venuesIds)
    venues = Venue.where(id: venues_ids)
    user = nil
    success = false
    ActiveRecord::Base.transaction do
      user = User.invite!(email: email, first_name: first_name, surname: surname, work_venues: venues) do |u|
        u.skip_invitation = true
      end
      role = user.add_role(role)
      success = user.valid? && role.valid?
      raise ActiveRecord::Rollback unless success
      user.deliver_invitation
    end
    Result.new(success, user, role, CreateInviteApiErrors.new(user: user, role: role))
  end

  private

  attr_reader :inviter
end
