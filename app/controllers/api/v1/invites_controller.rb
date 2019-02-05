class Api::V1::InvitesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  def index
    result = InvitesPageData.new(params: filter_params).all
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
    result = CreateInvite.new(inviter: current_user).call(params: invited_user_params)

    if result.success?
      full_result = InvitesPageData.new(params: filter_params).all
      pagination = Pagination.new(records: full_result.invited_users, current_page: page_from_params).for_load_more

      render json: {
        invitedUsers: ActiveModel::Serializer::CollectionSerializer.new(
          pagination[:records],
          serializer: Api::V1::Invites::InvitedUserSerializer,
        ),
        pagination: pagination[:pagination],
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

  def invited_user_params
    invited_user_data = params.fetch(:invitedUser)
    {
      email: invited_user_data.fetch(:email),
      first_name: invited_user_data.fetch(:firstName),
      surname: invited_user_data.fetch(:surname),
      role: invited_user_data.fetch(:role),
      venues_ids: invited_user_data.fetch(:venues),
    }
  end

  def page_from_params
    request.query_parameters[:page] || 1
  end

  def filter_params
    request.query_parameters
  end
end
