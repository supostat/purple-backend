FactoryBot.define do
  factory :user do
    first_name { "John" }
    surname  { "Doe" }
    email { 'john.doe@niceguy.net'}
    password { 'fake-password'}
  end
end