class Api::V1::InvitesController < ApplicationController
  before_action :authenticate_user!

  def index
      render json: {
        foo: 'bar'
      }
  end
end
