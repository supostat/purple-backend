class Api::V1::AcceptInvites::UserSerializer < ActiveModel::Serializer
  attributes \
    :firstName,
    :surname,
    :email

  def firstName
    object.first_name
  end
end
