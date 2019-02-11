class UserHistoryService
  SKIPPED_ATTRIBUTES = ["updated_at", "created_at", "id", "reset_password_token", "reset_password_sent_at"]

  def initialize(user: , requester:)
    @old_work_venues = get_venues(venues: user.work_venues)
    @old_role = user.roles_name[0]
    @user = user.dup
    @requester = requester
  end

  def create_history!(updated_user:)
    # activerecord-import gem uses here.
    # URL: https://github.com/zdennis/activerecord-import
    # REASON:
    # We need to create a batched records immediately, if we will just use
    # UserHistory.create(changes(updated_user: updated_user))
    # it will create records one by one, and the timestamps can be different between
    # first and last created records
    # activerecord-import gem solve this issue, it creates records in a one single query
    UsersHistory.import(changes(updated_user: updated_user))
  end

  def changes(updated_user:)
    updated_user_attributes = updated_user.attributes
    diff_handlers = attr_diff_handler(updated_user)
    new_work_venues = get_venues(venues: updated_user.work_venues)
    new_role = updated_user.roles_name[0]

    initial_history = []

    if old_work_venues&.sort_by { |hsh| hsh[:name] } != new_work_venues&.sort_by { |hsh| hsh[:name] }
      history = UsersHistory.new(requester_user: requester, model_key: "work_venues", user: updated_user)
      history.assign_attributes(diff_object(old_value: old_work_venues.to_json, new_value: new_work_venues.to_json))
      initial_history << history
    end

    if old_role != new_role
      history = UsersHistory.new(requester_user: requester, model_key: "role", user: updated_user)
      history.assign_attributes(diff_object(old_value: old_role, new_value: new_role))
      initial_history << history
    end

    user.attributes.inject(initial_history) do |acc, (key, value)|
      if !SKIPPED_ATTRIBUTES.include? key
        if updated_user_attributes[key] != value
          history = UsersHistory.new(requester_user: requester, model_key: key, user: updated_user)
          if diff_handlers.keys.include? key
            history.assign_attributes(diff_handlers[key].call)
            acc << history
          else
            history.assign_attributes(diff_object(old_value: value, new_value: updated_user_attributes[key]))
            acc << history
          end
        end
      end
      acc
    end
  end

  private

  def master_venue_diff(updated_user)
    diff_object(
      old_value: {id: user.master_venue&.id, name: user.master_venue&.name}.to_json,
      new_value: {id: updated_user.master_venue&.id, name: updated_user.master_venue&.name}.to_json,
    )
  end

  def attr_diff_handler(updated_user)
    {
      "master_venue_id" => -> { master_venue_diff(updated_user) },
    }
  end

  def diff_object(old_value:, new_value:)
    {
      old_value: old_value,
      new_value: new_value,
      requester_user: requester,
    }
  end

  def get_venues(venues:)
    return nil if !venues.present?
    venues.map { |venue| {id: venue.id, name: venue.name} }
  end

  attr_reader :user, :requester, :old_work_venues, :old_role
end
