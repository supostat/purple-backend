class Venue < ApplicationRecord
  has_and_belongs_to_many :users, :join_table => :users_venues

  validates :name, presence: true
end
