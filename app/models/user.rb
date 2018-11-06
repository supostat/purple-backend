class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :registerable,
         :jwt_authenticatable,
         otp_secret_encryption_key: ENV["OTP_SECRET_ENCRYPTION_KEY"],
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :email, presence: true
end
