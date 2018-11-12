class Api::V1::InvitesController < ApplicationController
  before_action :authenticate_user!

  def index
    result = InvitesPageData.new.all
    if result.success?
      render json: {
        invitedUsers: ActiveModel::Serializer::CollectionSerializer.new(
          result.users,
          serializer: Api::V1::Invites::InvitedUserSerializer,
        ),
      }
    end
  end
end
