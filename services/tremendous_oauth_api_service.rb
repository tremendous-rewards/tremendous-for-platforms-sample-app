require 'oauth2'

# Tremendous OAuth API Service
class TremendousOauthApiService
  attr_reader :organization

  def initialize(organization)
    @organization = organization
  end

  def fetch_access_token(oauth_code)
    @access_token = oauth_client
      .auth_code
      .get_token(oauth_code, redirect_uri: ENV["OAUTH_REDIRECT_URL"])

    update_organization
  end

  def get_organizations
    with_refresh_token_retry do
      JSON.parse(access_token.get("/api/v2/organizations").body)
    end
  end

  private

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(
      ENV["OAUTH_CLIENT_ID"],
      ENV["OAUTH_CLIENT_SECRET"],
      site: ENV["TREMENDOUS_SITE_URL"]
    )
  end

  def with_refresh_token_retry
    count = 0

    begin
      yield
    rescue OAuth2::Error => error
      if error.response.parsed.dig("errors", "message").start_with?("The API key you provided is no longer valid.")
        refresh_access_token

        retry unless count > 1
      end

      raise error
    end
  end

  def refresh_access_token
    @access_token = access_token.refresh!

    update_organization
  end

  def update_organization
    @organization.update!(
      tremendous_oauth_access_token: access_token.token,
      tremendous_oauth_refresh_token: access_token.refresh_token,
      tremendous_oauth_access_token_expires_at: Time.at(access_token.expires_at.to_i)
    )
  end

  def access_token
    @access_token ||= OAuth2::AccessToken.new(
      oauth_client,
      organization.tremendous_oauth_access_token,
      refresh_token: organization.tremendous_oauth_refresh_token,
      expires_at: organization.tremendous_oauth_access_token_expires_at,
    )
  end
end
