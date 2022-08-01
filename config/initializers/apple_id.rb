if Rails.env.development?
  AppleID.debug!
  Rack::OAuth2.logger = OpenIDConnect.logger = AppleID.logger = Rails.logger
end

AppleID::JWKS.cache = Rails.cache