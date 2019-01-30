class Api::V1::AcceptInvitesController < ApplicationController
  def index
    result = AcceptInvitePageData.new(invitation_token: invitation_token_from_params).all
    if result.success?
      render json: {
        invitedUser: Api::V1::AcceptInvites::UserSerializer.new(result.user),
        base64Png: result.base64Png,
      }
    else
      raise "qweqwe"
    end
  end

  def accept
    invitation_token = params.fetch(:invitationToken)
    user = User.find_by_invitation_token(invitation_token, true)
    if user.present? && user.invited_to_sign_up? && user.created_by_invite?
      user = AcceptInvite.new(user: user).call(params: params)
      sign_in(user)
    else
      render json: {erros: "error"}, status: 422
    end
  end

  private
  def invitation_token_from_params
    params.fetch(:invitationToken).transform_keys do |key|
      key.to_s.underscore.to_sym
    end
  end
end
