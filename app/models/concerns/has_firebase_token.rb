module HasFirebaseToken
  extend ActiveSupport::Concern

  class_methods do
    def decoded_firebase_token(bearer_token)
      firebase_project_id = Rails.application.credentials.dig(:FIREBASE, :PROJECT_ID)
      client = Faraday.new do |builder|
        builder.use :http_cache, store: Rails.cache, logger: Rails.logger
        builder.adapter Faraday.default_adapter
        builder.response :json
      end
      JWT.decode(bearer_token, nil, true, { algorithm: 'RS256' }) do |header|
        url = URI('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com')
        response = client.get(url)

        public_key = OpenSSL::X509::Certificate.new(response.body[header['kid']]).public_key
        decoded = JWT.decode(bearer_token, public_key, true,
                             { algorithm: 'RS256', verify_iat: true,
                               verify_aud: true, aud: firebase_project_id,
                               verify_iss: true,
                               iss: "https://securetoken.google.com/#{firebase_project_id}" })
        return decoded
      end
    end
  end
end