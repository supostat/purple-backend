class DisableUser
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

    if params.fetch(:never_rehire).nil?
      user.errors.add(:never_rehire, "should be present")
    else
      disabled_reason = params.fetch(:disabled_reason)
      never_rehire = BooleanString.parse_boolean(params.fetch(:never_rehire))
      would_rehire = !never_rehire

      user.update({
        disabled_by_user: requester,
        disabled_at: Time.current,
        disabled_reason: disabled_reason,
        would_rehire: would_rehire
      })
    end

    success = user.errors.empty?

    unless success
      api_errors = DisableUserApiErrors.new(user: user)
    end
    Result.new(success, user, api_errors)
  end

  attr_reader :requester
end
