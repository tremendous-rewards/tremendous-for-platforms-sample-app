class OrganizationsController < BaseController
  # Index
  get '/organizations' do
    @organizations = Organization.all
    erb :'organizations/index'
  end

  # New
  get '/organizations/new' do
    @organization = Organization.new

    erb :'organizations/new'
  end

  # Create
  post '/organizations' do
    @organization = Organization.new(params[:organization])
    if @organization.save
      redirect "/organizations/#{@organization.id}"
    else
      erb :'organizations/new'
    end
  end

  # Show
  get '/organizations/:id' do
    @organization = Organization.find(params[:id])

    if params[:with_api_call]
      @api_response = TremendousOauthApiService.new(@organization).get_organizations
    end

    erb :'organizations/show'
  end

  # Tremendous Setup
  post '/organizations/:id/tremendous_setup' do
    @organization = Organization.find(params[:id])

    begin
      # Tremendous API call to create the connected organization
      if @organization.tremendous_connected_organization_id.blank?
        response = TremendousApiService.create_connected_organization

        payload = response.fetch("connected_organization")
        @organization.update!(tremendous_connected_organization_id: payload.fetch("id"))
      end

      # Tremendous API call to create the connected organization member
      if @organization.tremendous_connected_organization_member_id.blank?
        response = TremendousApiService.create_connected_organization_member(
          connected_organization_id: @organization.tremendous_connected_organization_id,
          external_email: @organization.creator_email,
          external_name: @organization.creator_name
        )

        payload = response.fetch("connected_organization_member")
        @organization.update!(tremendous_connected_organization_member_id: payload.fetch("id"))
      end

      flash[:success] = "Organization successfully set up on Tremendous"
    rescue => e
      flash[:error] = "Failed to setup organization on Tremendous: #{e.message}"
    end

    redirect "/organizations/#{@organization.id}"
  end

  # Tremendous Flow
  get '/organizations/:id/tremendous_flow' do
    @organization = Organization.find(params[:id])
    session[:organization_id] = @organization.id

    response = TremendousApiService.create_connected_organization_member_session(
      connected_organization_member_id: @organization.tremendous_connected_organization_member_id,
      return_url: ENV["TREMENDOUS_RETURN_URL"] % { id: @organization.id }
    )

    payload = response.fetch("connected_organization_member_session")

    { url: payload.fetch("url") }.to_json
  end

  # Delete
  delete '/organizations/:id' do
    @organization = Organization.find(params[:id])
    @organization.destroy
    redirect '/organizations'
  end
end
