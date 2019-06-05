class SessionsController < ApplicationController
  def show
    if session[:id_token]
      @id_token = JSON::JWT.decode session[:id_token], :skip_verification
    else
      redirect_to root_url
    end
  end

  def new
  end

  def create
    case
    when request.post?
      session[:state] = SecureRandom.hex(8)
      redirect_to client.authorization_uri(
        state: session[:state]
      )
    when params[:code] && session[:state] == params[:state]
      client.authorization_code = params[:code]
      token_response = client.access_token!
      token_response.id_token.verify! client, access_token: token_response.access_token
      session[:id_token] = token_response.id_token.original_jwt
      redirect_to session_url
    else
      redirect_to root_url
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
