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

    after :create do |user|
      # For Two Factor Auth we need to generate otp_secret
      # Then we can get `user.current_otp` code from the user model
      # It's like the user already scan his QR code on GoogleAuthenticator
      # and receiving the codes to sign in
      user.otp_secret = user.class.generate_otp_secret
      user.consumed_timestep = nil
    end

    before :create do |user, evaluator|
      # prefer explictly roles setting
      if user.roles.present? && evaluator.role.present?
        raise 'conflicting attempt to set role and roles'
      end

      if !user.roles.present?
        _role = evaluator.role || Role::MANAGER_ROLE
        _role_model = Role.find_or_create_by(name: _role)
        user.roles = [_role_model]
      end
    end

    trait :invited do
      password { nil }
      password_confirmation { nil }
      invitation_created_at { Time.current }
      invitation_sent_at { Time.current }
    end

    trait :admin do
      after(:create) {|user| user.add_role(Role::ADMIN_ROLE)}
    end

    trait :manager do
      after(:create) {|user| user.add_role(Role::MANAGER_ROLE)}
    end

    trait :disabled do
      after(:build) {|user| user.update({
        disabled_reason: "Reason",
        disabled_at: Time.current,
        disabled_by_user: FactoryBot.create(:user)
      })}
    end
  end
end
