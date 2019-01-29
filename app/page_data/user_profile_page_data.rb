class UserProfilePageData
  Result = Struct.new(:success, :user, :roles, :venues) do
    def success?
      success
    end
  end

  def initialize(user_id:)
    @user_id = user_id
  end

  def all
    success = true
    user = User.created_by_invite.find_by(id: user_id)
    roles = Role::ROLES_TITLES
    venues = Venue.all
    Result.new(success, user, roles, venues)
  end

  private

  attr_reader :user_id
end
