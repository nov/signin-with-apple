if Rails.env.development?
  AppleID.debug!
  AppleID.logger = Rails.logger
end

AppleID::JWKS.cache = Rails.cache