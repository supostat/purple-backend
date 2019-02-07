class Api::V1::UserProfile::UserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :role,
    :invitedAt,
    :venuesIds,
    :firstName,
    :surname,
    :status,
    :flagged,
    :enabled,
    :disabled,
    :disabledReason,
    :disabledBy

  def invitedAt
    object.invitation_sent_at
  end

  def venuesIds
    object.work_venues.pluck(:id)
  end

  def role
    object.roles_name[0]
  end

  def firstName
    object.first_name
  end

  def surname
    object.surname
  end

  def status
    object.status
  end

  def enabled
    !object.disabled?
  end

  def disabled
    object.disabled?
  end

  def disabledReason
    object.disabled_reason
  end

  def disabledBy
    object.disabled_by_user&.full_name
  end

  def flagged
    object.flagged?
  end
end
