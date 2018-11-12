class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_role? :admin
    can :manage, User
  end
end