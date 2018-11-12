class InvitesPageData
  Result = Struct.new(:success, :users, :roles, :venues) do
    def success?
      success
    end
  end

  def all
    success = true
    users = User.created_by_invite
    roles = Role::ROLES
    venues = Venue.all
    Result.new(success, users, roles, venues)
  end
end
