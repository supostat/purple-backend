module HeaderHelpers
  def set_authorization_header(user)
    header_data = Devise::JWT::TestHelpers.auth_headers({}, user)
    header_key = 'Authorization'
    header(header_key, header_data.fetch(header_key))
  end

  def set_controller_spec_headers(user)
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    request.headers.merge! Devise::JWT::TestHelpers.auth_headers(headers, user)
  end
end
