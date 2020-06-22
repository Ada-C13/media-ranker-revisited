Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], scope: "user:email"
end

# reference: https://github.com/Ada-Developers-Academy/textbook-curriculum/blob/master/09-intermediate-rails/oauth.md