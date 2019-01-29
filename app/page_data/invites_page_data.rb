class InvitesPageData
  Result = Struct.new(:success, :invited_users, :roles, :venues, :invitation_statuses) do
    def success?
      success
    end
  end

  def initialize(params:)
    @params = params
  end

  def all
    success = true
    invited_users = InvitesIndexQuery.new(params: params).all

    roles = Role::ROLES_TITLES
    venues = Venue.all
    invitation_statuses = User::INVITATION_STATUSES_TEXT
    Result.new(success, invited_users, roles, venues, invitation_statuses)
  end

  private

  attr_reader :page, :params
end
