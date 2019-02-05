module HeaderHelpers
  def set_authorization_header(user)
    header_data = Devise::JWT::TestHelpers.auth_headers({}, user)
    header_key = 'Authorization'
    header(header_key, header_data.fetch(header_key))
  end
end
