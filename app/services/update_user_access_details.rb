class UpdateUserAccessDetails
  Result = Struct.new(:success, :user, :api_errors) do
    def success?
      success
    end
  end

  def initialize(requester:)
    @requester = requester
  end

  def call(params:)
    success = false
    api_errors = nil
    user_id = params.fetch(:id)
    role = params.fetch(:role)
    work_venues = Venue.where(id: params.fetch(:work_venues_ids))
    user = User.find_by({id: user_id})
    changes = UserHistoryService.new(user: user, requester: requester)

    ActiveRecord::Base.transaction do
      user.update(work_venues: work_venues)
      user.roles.delete_all
      role = user.add_role(role)
      success = user.errors.empty? && role.errors.empty?
      raise ActiveRecord::Rollback unless success
    end

    if success
      changes.create_history!(updated_user: user)
    else
      api_errors = UpdateUserAccessDetailsApiErrors.new(user: user, role: role)
    end
    Result.new(success, user, api_errors)
  end

  private

  attr_reader :requester
end
