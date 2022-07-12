class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event_token = AppleID::EventToken.decode params[:payload]
    event_token.verify!
    Event.create!(
      identifier: event_token.jti,
      payload: event_token.to_json
    )
    head 200
  rescue AppleID::EventToken::VerificationFailed
    head 400
  end
end
