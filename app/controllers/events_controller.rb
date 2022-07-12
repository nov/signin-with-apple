class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    logger.info request.body
    head 200
  end
end
