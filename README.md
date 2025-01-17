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

## Services

### TremendousApiService
Located in `services/tremendous_api_service.rb`
- Handles direct API interactions with Tremendous
- Core functionalities:
  - Creating connected organizations
  - Creating connected organization members
  - Creating member sessions

### TremendousOauthApiService
Located in `services/tremendous_oauth_service.rb`
- Manages OAuth2 authentication flow with Tremendous
- Core functionalities:
  - Fetching access tokens
  - Refreshing tokens
  - Making authenticated API calls with OAuth
