class DeliverInviteEmail
  def call(user:)
    user.deliver_invitation
  end
end
