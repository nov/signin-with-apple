class SessionsController < ApplicationController
  def show

  end

  def new
  end

  def create
    case
    when request.post?
      redirect_to client.authorization_uri
    else

    end
  end

  private

  def client
    @client ||= AppleID::Client.new(
      identifier: ENV['CLIENT_ID'],
      team_id: ENV['TEAM_ID'],
      key_id: ENV['KEY_ID'],
      private_key: OpenSSL::PKey::EC.new(ENV['PRIVATE_KEY']),
      redirect_uri: ENV['REDIRECT_URI']
    )
  end
end
