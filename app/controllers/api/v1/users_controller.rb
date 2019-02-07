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
    result = UserProfileHistoryQuery.new(params: history_params).all
    render json: {
      history: ActiveModel::Serializer::CollectionSerializer.new(
        result,
        serializer: Api::V1::UserProfile::UserHistorySerializer,
      ),
    }
  end

  def update_personal_details
    result = UpdateUserPersonalDetails.new(requester: current_user).call(params: update_personal_details_params)
    if result.success?
      render json: {
        user: Api::V1::Users::UserSerializer.new(result.user),
      }, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  def update_access_details
    result = UpdateUserAccessDetails.new(requester: current_user).call(params: update_access_details_params)
    if result.success?
      render json: {
        user: Api::V1::Users::UserSerializer.new(result.user),
      }, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  def disable
    result = DisableUser.new(requester: current_user).call(params: disable_params)
    if result.success?
      render json: {
        user: Api::V1::Users::UserSerializer.new(result.user),
      }, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  def enable
    result = EnableUser.new.call(params: enable_params)
    if result.success?
      render json: {
        user: Api::V1::Users::UserSerializer.new(result.user),
      }, status: 200
    else
      render json: {
        errors: result.api_errors.errors,
      }, status: 422
    end
  end

  private

  def history_params
    {
      id: params.fetch(:id),
    }.merge(query_params)
  end

  def query_params
    request.query_parameters
  end

  def update_personal_details_params
    {
      id: params.fetch(:id),
      first_name: params.fetch(:firstName),
      surname: params.fetch(:surname),
      email: params.fetch(:email),
    }
  end

  def update_access_details_params
    {
      id: params.fetch(:id),
      role: params.fetch(:role),
      work_venues_ids: params.fetch(:venues),
    }
  end

  def disable_params
    {
      id: params.fetch(:id),
      disabled_reason: params.fetch(:disabledReason),
      never_rehire: params.fetch(:neverRehire),
    }
  end

  def enable_params
    {
      id: params.fetch(:id)
    }
  end

  def current_ability
    @current_ability ||= ::UsersAbility.new(current_user)
  end
end
