FactoryBot.define do
  factory :user do
    transient do
      role { nil }
    end

    first_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }

    before :create do |user, evaluator|
      _role = evaluator.role || Role::MANAGER_ROLE
      _role_model = Role.find_or_create_by(name: _role)
      user.roles = [_role_model]
    end
  end
end
