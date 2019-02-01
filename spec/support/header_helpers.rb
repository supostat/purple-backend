module HeaderHelpers
  def set_authorization_header(user)
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    request.headers.merge! Devise::JWT::TestHelpers.auth_headers(headers, user)
  end
end
