
class Api::V1::UserProfile::UserHistorySerializer < ActiveModel::Serializer
  attributes \
    :id,
    :key,
    :oldValue,
    :newValue,
    :updatedBy,
    :updatedAt

  def key
    object.model_key
  end

  def oldValue
    object.old_value
  end

  def newValue
    object.new_value
  end

  def updatedBy
    object.requester_user&.full_name
  end

  def updatedAt
    object.created_at.iso8601
  end

  def endsAt
    object.ends_at.utc.iso8601
  end
end
