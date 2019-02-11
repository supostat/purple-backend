class UsersPageData
  Result = Struct.new(:success, :users, :roles, :venues, :statuses) do
    def success?
      success
    end
  end

  def initialize(params:)
    @params = params
  end

  def all
    success = true
    users = UsersIndexQuery.new(params: params).all
    roles = Role::ROLES_TITLES
    venues = Venue.all
    statuses = User::STATUSES_TEXT
    Result.new(success, users, roles, venues, statuses)
  end

  private

  attr_reader :params
end
