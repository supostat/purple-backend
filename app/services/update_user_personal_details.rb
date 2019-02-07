class UpdateUserPersonalDetails
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

    user = User.find_by({id: user_id})
    changes = UserHistoryService.new(user: user, requester: requester)
    success = user.update(params)
    if success
      changes.create_history!(updated_user: user)
    else
      api_errors = UpdateUserPersonalDetailsApiErrors.new(user: user)
    end
    Result.new(success, user, api_errors)
  end

  private

  attr_reader :requester
end
