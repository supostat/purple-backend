class Api::V1::Invites::InvitedUserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :role,
    :invitedAt

  def invitedAt
    object.invitation_sent_at
  end
end
