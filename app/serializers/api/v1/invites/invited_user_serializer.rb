class Api::V1::Invites::InvitedUserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :role,
    :invitedAt,
    :venuesIds,
    :invitationStatus,
    :inviterFullName

  def invitedAt
    object.invitation_sent_at.iso8601
  end

  def venuesIds
    object.work_venues.pluck(:id)
  end

  def role
    object.roles.pluck(:name)[0]
  end

  def invitationStatus
    object.invitation_status
  end

  def inviterFullName
    object.invited_by&.full_name
  end
end
