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

  def show
    result = UserProfilePageData.new(user_id: params.fetch(:id)).all

    render json: {
      user: Api::V1::UserProfile::UserSerializer.new(result.user),
      venues: ActiveModel::Serializer::CollectionSerializer.new(
        result.venues,
        serializer: Api::V1::UserProfile::VenueSerializer,
      ),
      roles: result.roles,
    }, status: 200
  end

  def history
    render json: {
      history: [],
    }
  end

  private

  def current_ability
    @current_ability ||= ::InvitesAbility.new(current_user)
  end
end
