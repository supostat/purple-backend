class CreateInvite
  Result = Struct.new(:success, :invited_user, :role, :api_errors) do
    def success?
      success
    end
  end

  def initialize(inviter: nil, invitiation_delivery_service: DeliverInviteEmail.new, ability: InvitesAbility.new(inviter))
    @inviter = inviter
    @invitiation_delivery_service = invitiation_delivery_service
    @ability = ability
  end

  def call(params:)
    ability.authorize!(:create, User, :message => "Unable to create invite.")

    invited_user = nil
    success = false
    api_errors = nil
    email = params.fetch(:email)
    first_name = params.fetch(:first_name)
    surname = params.fetch(:surname)
    role = Role.find_by(name: params.fetch(:role))
    roles = [role].compact
    work_venues = Venue.where(id: params.fetch(:venues_ids))

    ActiveRecord::Base.transaction do
      invited_user = User.invite!(
        {
          email: email,
          first_name: first_name,
          surname: surname,
          work_venues: work_venues,
          roles: roles,
        },
        inviter
      ) do |u|
        u.skip_invitation = true
      end
      success = invited_user.errors.empty?
      raise ActiveRecord::Rollback unless success
      invitiation_delivery_service.call(user: invited_user)
    end

    unless success == true
      api_errors = CreateInviteApiErrors.new(invited_user: invited_user)
    end

    Result.new(success, invited_user, role, api_errors)
  end

  private

  attr_reader :inviter, :invitiation_delivery_service, :ability
end
