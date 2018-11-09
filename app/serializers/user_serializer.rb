class UserSerializer < ActiveModel::Serializer
  attributes \
    :firstName,
    :surname,
    :email

  def firstName
    object.first_name
  end
end
