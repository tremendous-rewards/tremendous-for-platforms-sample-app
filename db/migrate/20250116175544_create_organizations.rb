class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :creator_email
      t.string :creator_name
      t.timestamps

      # Tremendous fields
      t.string :tremendous_connected_organization_id
      t.string :tremendous_organization_id
      t.string :tremendous_connected_organization_member_id
      t.string :tremendous_oauth_access_token
      t.string :tremendous_oauth_refresh_token
      t.datetime :tremendous_oauth_access_token_expires_at
    end
  end
end
