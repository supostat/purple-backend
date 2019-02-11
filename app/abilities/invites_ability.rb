class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_any_role?(Role::ADMIN_ROLE, Role::MANAGER_ROLE)

    can :show, User
    can :revoke, User

    if user.has_role? Role::ADMIN_ROLE
      can :create, User
    end
  end
end
