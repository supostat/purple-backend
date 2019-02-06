class Api::V1::AcceptInvitesController < ApplicationController
  def index
    user = User.find_by(invitation_token: invitation_token_from_params)

    if user.present?
      result = AcceptInvitePageData.new(user: user).call

      render json: {
        invitedUser: Api::V1::AcceptInvites::UserSerializer.new(result.user),
        base64Png: result.base64Png,
      }
    else
      render json: {}, status: :forbidden
    end
  end

  def accept
    invitation_token = accept_invite_params.fetch(:invitation_token)

    # devise finder used to match by hidden raw_invitation_token field
    only_valid = true
    user = User.find_by_invitation_token(invitation_token, only_valid)

    if user.present? && user.invited_to_sign_up? && user.created_by_invite?
      result = AcceptInvite.new.call(params: accept_invite_params)

      if result.success?
        sign_in(result.user)
        render json: {}, status: :ok
      else
        api_errors = result.api_errors
        render json: { errors: api_errors.errors }, status: 422
      end
    else
      render json: {}, status: :unauthorized
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
