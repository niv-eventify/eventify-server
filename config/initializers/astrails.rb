module Astrails
  def self.generate_token
    SecureRandom.base64(16).tr('+/=', '-_ ').strip.delete("\n")
  end
end