class Api::V1::AcceptInvitesController < ApplicationController
  def index
    result = AcceptInvitePageData.new(invitation_token: invitation_token_from_params).call

    render json: {
      invitedUser: Api::V1::AcceptInvites::UserSerializer.new(result.user),
      base64Png: result.base64Png,
    }
  end

  def accept
    invitation_token = accept_invite_params.fetch(:invitation_token)
    user = User.find_by_invitation_token(invitation_token, true)
    if user.present? && user.invited_to_sign_up? && user.created_by_invite?
      user = AcceptInvite.new(user: user).call(params: accept_invite_params)
      sign_in(user)
    else
      render json: {erros: "error"}, status: 422
    end
  end

  private
  def invitation_token_from_params
    params.fetch(:invitationToken)
  end

  def accept_invite_params
    {
      auth_code: params.fetch(:authCode),
      invitation_token: params.fetch(:invitationToken),
      password: params.fetch(:password),
      password_confirmation: params.fetch(:passwordConfirmation),
    }
  end
end
