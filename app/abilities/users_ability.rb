class UsersAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.has_any_role?(:manager, :admin)
    if user.has_role? :manager
      can :index, User
      can :show, User
      can :history, User
      can :update_personal_details, User
      can :update_access_details, User
      can :enable, User
      can :disable, User
    end
    if user.has_role? :admin
      can :manage, User
    end
  end
end