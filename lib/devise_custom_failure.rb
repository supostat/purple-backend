class DeviseCustomFailure < Devise::FailureApp
  def respond
    if http_auth?
      http_auth
    else
      self.status = 401
      self.content_type = "application/json"
      self.response_body = {success: false, error: "Unauthorized"}.to_json
    end
  end
end