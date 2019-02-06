class InvitesAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_any_role?(Role::MANAGER_ROLE, Role::ADMIN_ROLE)

    can :view, :invites_index do
      user.has_role? Role::ADMIN_ROLE
    end

    can :create_invites do
      user.has_role? Role::ADMIN_ROLE
    end

    can :revoke_invite, User do |invite_user|
      user.has_role? Role::ADMIN_ROLE
    end
  end
end
