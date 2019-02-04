class RevokeInvite
  def initialize(invited_user:, requester:, ability: InvitesAbility.new(requester))
    @invited_user = invited_user
    @requester = requester
    @ability = ability
  end
  attr_reader :invited_user, :ability, :requester

  def call(now: Time.current)
    ability.authorize!(:revoke_invite, invited_user)

    raise "attempt to revoke invite ##{id} which is already revoked" if invited_user.invitation_revoked?
    raise "attempt to revoke invite ##{id} which is already accepted" if invited_user.invitation_accepted?
    raise "attempt to revoke invite for user ##{id} who is not currently invited" if !invited_user.invited_to_sign_up?

    invited_user.update_attributes!({
      invitation_revoked_at: now,
      invitation_token: nil,
    })
  end
end
