class Api::V1::Invites::InvitedUserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :roles,
    :invitedAt,
    :venuesIds

  def invitedAt
    object.invitation_sent_at
  end

  def venuesIds
    object.work_venues.pluck(:id)
  end

  def roles
    object.roles_name
  end
end
