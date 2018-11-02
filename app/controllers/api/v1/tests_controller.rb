class Api::V1::TestsController < ApplicationController
  # before_action :authenticate_user!

  def index
    render json: {hello: "World"}
  end
end
