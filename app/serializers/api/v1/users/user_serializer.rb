class Api::V1::Users::UserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :role,
    :invitedAt,
    :venuesIds,
    :firstName,
    :surname,
    :status

  def invitedAt
    object.invitation_sent_at
  end

  def venuesIds
    object.work_venues.pluck(:id)
  end

  def role
    object.role
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
end
