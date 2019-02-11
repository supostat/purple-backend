class RevokeInvite
  def initialize(invited_user:, requester:, ability: InvitesAbility.new(requester))
    @invited_user = invited_user
    @requester = requester
    @ability = ability
  end
  attr_reader :invited_user, :ability, :requester

  def call(now: Time.current)
    ability.authorize!(:revoke, invited_user)

    raise self.class.invite_already_revoked_error_message(invited_user) if invited_user.invitation_revoked?
    raise self.class.invite_already_accepted_error_message(invited_user) if invited_user.invitation_accepted?
    raise self.class.not_invited_error_message(invited_user) if !invited_user.invited_to_sign_up?

    invited_user.update_attributes!({
      invitation_revoked_at: now,
      invitation_token: nil,
    })
  end

  def self.invite_already_revoked_error_message(user)
    "attempt to revoke invite ##{user.id} which is already revoked"
  end

  def self.invite_already_accepted_error_message(user)
    "attempt to revoke invite ##{user.id} which is already accepted"
  end

  def self.not_invited_error_message(user)
    "attempt to revoke invite for user ##{user.id} who is not currently invited"
  end
end
