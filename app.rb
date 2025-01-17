require 'dotenv/load'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'

require './models/organization'
require './services/tremendous_api_service'
require './services/tremendous_oauth_api_service'
require './controllers/base_controller'
require './controllers/organizations_controller'
require './controllers/webhooks_controller'

set :database, { adapter: 'sqlite3', database: 'db/development.sqlite3' }

class Application < BaseController
  use OrganizationsController
  use WebhooksController

  get '/' do
    redirect '/organizations'
  end

  get '/callback' do
    organization_id = session[:organization_id]
    organization = Organization.find(organization_id)

    begin
      TremendousOauthApiService.new(organization).fetch_access_token(params[:code])
      flash[:success] = "OAuth setup complete"
    rescue => e
      flash[:error] = "Failed to fetch access token: #{e.message}"
    end

    redirect "/organizations/#{organization_id}"
  end
end
