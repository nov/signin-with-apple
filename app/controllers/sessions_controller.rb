class SessionsController < ApplicationController
  before_action :setup_state, only: :new
  before_action :setup_client, only: [:create, :callback]
  skip_before_action :verify_authenticity_token, only: :callback

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
    redirect_to @client.authorization_uri(
      scope: [:email, :name],
      state: session[:state],
      nonce: session[:nonce]
    )
  end

  def callback
    if params[:code].present? && session.delete(:state) == params[:state]
      @client.authorization_code = params[:code]
      token_response = @client.access_token!
      token_response.id_token.verify!(
        client: @client,
        access_token: token_response.access_token,
        # nonce: session.delete(:nonce) # NOTE: JS SDK isn't supporting nonce yet.
      )
      session[:id_token] = token_response.id_token.original_jwt.to_s
      redirect_to session_url
    else
      redirect_to root_url
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
    session[:nonce] = SecureRandom.hex(8)
  end
end
