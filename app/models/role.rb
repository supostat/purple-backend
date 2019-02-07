class Role < ApplicationRecord
has_and_belongs_to_many :users, :join_table => :users_roles

ADMIN_ROLE = "admin"
MANAGER_ROLE = "manager"

ROLES = [ADMIN_ROLE, MANAGER_ROLE]

ROLES_TITLES = {
  ADMIN_ROLE => "Admin",
  MANAGER_ROLE => "Manager",
}

belongs_to :resource,
           :polymorphic => true,
           :optional => true


validates :resource_type,
          :inclusion => { :in => Rolify.resource_types },
          :allow_nil => true

validates :name, presence: true, :inclusion => { :in => ROLES }
scopify
end
