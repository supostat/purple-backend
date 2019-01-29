class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_role? :manager
    can :manage, User
  end
end