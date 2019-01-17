class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  def index
    result = UsersPageData.new.all
    if result.success?
      render json: {
        users: ActiveModel::Serializer::CollectionSerializer.new(
          result.users,
          serializer: Api::V1::Users::UserSerializer,
        ),
        roles: result.roles,
        venues: ActiveModel::Serializer::CollectionSerializer.new(
          result.venues,
          serializer: Api::V1::Users::VenueSerializer,
        ),
      }, status: 200
    end
  end

  def current_ability
    @current_ability ||= ::InvitesAbility.new(current_user)
  end
end
