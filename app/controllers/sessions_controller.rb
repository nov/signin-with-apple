class SessionsController < ApplicationController
  before_filter :setup_state, only: :new
  before_filter :setup_client, only: :create

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
<<<<<<< HEAD
    when request.post?
      session[:state] = SecureRandom.hex(8)
      redirect_to client.authorization_uri(
        state: session[:state]
      )
    when params[:code] && session[:state] == params[:state]
      client.authorization_code = params[:code]
      token_response = client.access_token!
      token_response.id_token.verify!(
        client: client,
        access_token: token_response.access_token
      )
      session[:id_token] = token_response.id_token.original_jwt.to_s
      redirect_to session_url
    else
=======
    when params[:error].present?
>>>>>>> play with apple js sdk
      redirect_to root_url
    when params[:code].present? && session[:state] == params[:state]
      receive_authorization_response
    else
      send_authorization_request
    end
  end

  private

  def setup_client
    @client ||= AppleID::Client.new(
      identifier: ENV['CLIENT_ID'],
      team_id: ENV['TEAM_ID'],
      key_id: ENV['KEY_ID'],
      private_key: OpenSSL::PKey::EC.new(ENV['PRIVATE_KEY']),
      redirect_uri: ENV['REDIRECT_URI']
    )
  end

  def setup_state
    session[:state] = SecureRandom.hex(8)
  end

  def send_authorization_request
    redirect_to @client.authorization_uri(
      scope: [:email, :name],
      state: session[:state]
    )
  end

  def receive_authorization_response
    @client.authorization_code = params[:code]
    token_response = @client.access_token!
    token_response.id_token.verify!(
      client: @client,
      access_token: token_response.access_token
    )
    session[:id_token] = token_response.id_token.original_jwt.to_s
    redirect_to session_url
  end
end
