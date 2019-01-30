FactoryBot.define do
  factory :venue do
    sequence :name do |n|
      "Venue #{n}"
    end
  end
end
