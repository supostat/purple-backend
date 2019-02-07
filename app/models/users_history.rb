class UsersHistory < ApplicationRecord
  belongs_to :requester_user, class_name: 'User'
  belongs_to :user

  validates :model_key, presence: true
  validates :requester_user, presence: true
  validates :user, presence: true
end
