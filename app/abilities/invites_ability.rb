class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_any_role?(Role::MANAGER_ROLE, Role::ADMIN_ROLE)

    can :view, :invites_index do
      user.has_role? Role::MANAGER_ROLE
    end

    can :create_invites do
      user.has_role? Role::MANAGER_ROLE
    end
  end
end
