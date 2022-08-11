# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

if Rails.application.credentials.dig(:CORS_ORIGINS).present?
  Rails.application.credentials.dig(:CORS_ORIGINS).each do |origin|
    Rails.application.config.hosts << origin
  end

  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins Rails.application.credentials.dig(:CORS_ORIGINS)

      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head]
    end
  end
end
