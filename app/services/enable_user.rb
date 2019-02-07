class EnableUser
  Result = Struct.new(:success, :user, :api_errors) do
    def success?
      success
    end
  end

  def call(params:)
    success = false
    api_errors = nil
    user_id = params.fetch(:id)
    user = User.find_by({id: user_id})
    user.update({disabled_by_user: nil, disabled_at: nil, disabled_reason: nil})
    success = user.errors.empty?

    unless success
      api_errors = EnableUserApiErrors.new(user: user)
    end
    Result.new(success, user, api_errors)
  end

  attr_reader :requester
end
