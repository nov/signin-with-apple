class EventsController < ApplicationController
  def create
    logger.info request.body
    head 200
  end
end
