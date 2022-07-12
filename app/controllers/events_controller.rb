class EventsController < ApplicationController
  def create
    logger.info params
    head 200
  end
end
