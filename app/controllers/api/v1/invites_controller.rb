class Api::V1::InvitesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  def index
    result = InvitesPageData.new.all
    if result.success?
      render json: {
        invitedUsers: ActiveModel::Serializer::CollectionSerializer.new(
          result.users,
          serializer: Api::V1::Invites::InvitedUserSerializer,
        ),
        roles: result.roles,
        venues: ActiveModel::Serializer::CollectionSerializer.new(
          result.venues,
          serializer: Api::V1::Invites::VenueSerializer,
        ),
      }, status: 200
    end
  end

  def create
    result = CreateInvite.new(inviter: current_user).call(params: params)
    if result.success?
      render json: {
        invitedUsers: ActiveModel::Serializer::CollectionSerializer.new(
          result.users,
          serializer: Api::V1::Invites::InvitedUserSerializer,
        ),
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
end
