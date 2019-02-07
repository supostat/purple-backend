class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_any_role?(:manager, :admin)
    can :manage, User
  end
end