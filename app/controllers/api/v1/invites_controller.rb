class Api::V1::InvitesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  def index
    result = InvitesPageData.new(params: params).all
    pagination = Pagination.new(records: result.invited_users, current_page: page_from_params).for_load_more
    if result.success?
      render json: {
        invitedUsers: ActiveModel::Serializer::CollectionSerializer.new(
          pagination[:records],
          serializer: Api::V1::Invites::InvitedUserSerializer,
        ),
        roles: result.roles,
        invitationStatuses: result.invitation_statuses,
        venues: ActiveModel::Serializer::CollectionSerializer.new(
          result.venues,
          serializer: Api::V1::Invites::VenueSerializer,
        ),
        pagination: pagination[:pagination],
      }, status: 200
    end
  end

  def create
    result = CreateInvite.new(inviter: current_user).call(params: params)
    if result.success?
      render json: {
        invitedUser: Api::V1::Invites::InvitedUserSerializer.new(result.invited_user)
      }, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  def current_ability
    @current_ability ||= ::InvitesAbility.new(current_user)
  end

  private

  def page_from_params
    params[:page] || 1
  end
end
