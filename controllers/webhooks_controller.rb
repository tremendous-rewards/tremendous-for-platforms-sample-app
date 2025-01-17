class WebhooksController < BaseController
  PRIVATE_KEY = ENV['TREMENDOUS_WEBHOOK_PRIVATE_KEY']

  before '/webhooks' do
    content_type :json

    @request_payload = JSON.parse(request.body.read)
  end

  post '/webhooks' do
    unless valid_signature?(request)
      halt 401, { error: 'Invalid signature' }.to_json
    end

    meta = @request_payload.dig('payload', 'meta')
    tremendous_connected_organization_id = meta.dig('id')
    organization = Organization.find_by!(tremendous_connected_organization_id: tremendous_connected_organization_id)

    case @request_payload['event']
    when 'CONNECTED_ORGANIZATIONS.REGISTERED'
      tremendous_organization_id = meta.dig('organization', 'id')
      organization.update!(tremendous_organization_id: tremendous_organization_id)
    when 'CONNECTED_ORGANIZATIONS.OAUTH.GRANTED'
      oauth_code = meta.dig('oauth_code')

      begin
        TremendousOauthApiService.new(organization).fetch_access_token(oauth_code)
      rescue => e
        puts "Failed to fetch access token: #{e.message}"
      end
    end

    { message: 'Webhook received' }.to_json
  end

  private

  def valid_signature?(request)
    signature_header = request.env['HTTP_TREMENDOUS_WEBHOOK_SIGNATURE']
    return false if signature_header.blank?

    algorithm, received_signature = signature_header.split('=', 2)

    expected_signature = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      PRIVATE_KEY,
      @request_payload.to_json
    )

    received_signature == expected_signature
  end
end
