class SessionsController < ApplicationController
  before_action :setup_state, only: :new
  before_action :setup_client, only: [:create, :callback]
  skip_before_action :verify_authenticity_token, only: :callback

  def show
    if session[:id_token_back_channel]
      @id_token_back_channel = JSON::JWT.decode session[:id_token_back_channel], :skip_verification
      if session[:id_token_front_channel]
        @id_token_front_channel = JSON::JWT.decode session[:id_token_front_channel], :skip_verification
      end
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
      nonce: session[:nonce],
      response_mode: :form_post
    )
  end

  def callback
    if params[:code].present? && session.delete(:state) == params[:state]
      expected_nonce = session.delete(:nonce)
      @client.authorization_code = params[:code]
      token_response = @client.access_token!
      id_token_back_channel = token_response.id_token
      id_token_back_channel.verify!(
        client: @client,
        access_token: token_response.access_token,
        # nonce: expected_nonce # NOTE: JS SDK isn't supporting nonce yet.
      )
      session[:id_token_back_channel] = id_token_back_channel.original_jwt.to_s
      if params[:id_token].present?
        id_token_front_channel = AppleID::IdToken.decode params[:id_token]
        id_token_front_channel.verify!(
          client: @client,
          code: params[:code],
          # nonce: expected_nonce # NOTE: JS SDK isn't supporting nonce yet.
        )
        session[:id_token_front_channel] = id_token_front_channel.original_jwt.to_s
      end
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
    reset_session
    session[:state] = SecureRandom.hex(8)
    session[:nonce] = SecureRandom.hex(8)
  end
end
