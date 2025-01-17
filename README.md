# Platform Clients Sample App

A minimal Sinatra application for managing organizations and the integration with Tremendous.

## Requirements

- Ruby 2.7+
- Bundler
- SQLite3

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Create database and run migrations:
   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   ```

3. Configure your environment:
   - Check `.env.example` to see what environment variables are needed
   - Create your own `.env`, using `.env.example` file as a base, and update the blank keys with the appropriate values for your environment

4. Start the server:
   ```bash
   bundle exec rackup
   ```

5. Visit http://localhost:9292 in your browser
   1. The application starts with the organizations page
   2. Click on the "New Organization" button to add a new organization and fill in the form
   3. Click "Set up on Tremendous" to create the appropriate setup on Tremendous; you only need to do this once per organization
   4. You'll then see a new button "Open Tremendous flow for X"; clicking it will start the flow on Tremendous's side
   5. Once your newly created organization is reviewed and approved by Tremendous, and the webhook has
   been processed, the "OAuth Status" will change to "Connected"

6. If you need the app to be accessible from another machine (for example, to test webhooks), boot the app with:
   ```bash
   RACK_ENV=production bundle exec rackup -o 0.0.0.0
   ```

   And then you can use `ngrok` or a similar tunneling service:
   ```bash
   ngrok http 9292
   ```

   Use that public URL when configuring the callback and webhook endpoints on Tremendous:
   - `return_uri` when [registering the OAuth application](https://developers.tremendous.com/docs/oauth-20#step-1-register-a-developer-app): `https://<your-ngrok-domain>/callback`
   - `url` when [configuring the webhook](https://developers.tremendous.com/reference/create-webhook): `https://<your-ngrok-domain>/webhooks`

## Controllers

### OrganizationsController
Located in `controllers/organizations_controller.rb`
- Handles all organization-related routes
- Core functionalities:
  - CRUD operations for organizations
  - Setting up an organization on Tremendous
  - Starting the platform clients flow on Tremendous
- Key endpoints:
  - `GET /organizations` - List all organizations
  - `GET /organizations/new` - New organization form
  - `POST /organizations` - Create organization
  - `GET /organizations/:id` - Show organization details
  - `POST /organizations/:id/tremendous_setup` - Initialize Tremendous setup
  - `GET /organizations/:id/tremendous_flow` - Start Tremendous flow

### WebhooksController
Located in `controllers/webhooks_controller.rb`
- Handles incoming webhooks from Tremendous
- Processes two main webhook events:
  - `CONNECTED_ORGANIZATIONS.REGISTERED`
  - `CONNECTED_ORGANIZATIONS.OAUTH.GRANTED`
- Includes webhook signature validation for security

## Services

### TremendousApiService
Located in `services/tremendous_api_service.rb`
- Handles direct API interactions with Tremendous
- Core functionalities:
  - Creating connected organizations
  - Creating connected organization members
  - Creating member sessions
- Uses HTTParty for API requests

### TremendousOauthApiService
Located in `services/tremendous_oauth_service.rb`
- Manages OAuth2 authentication flow with Tremendous
- Core functionalities:
  - Fetching access tokens
  - Refreshing tokens
  - Making authenticated API calls with OAuth tokens
- Uses the `oauth2` gem for OAuth operations
