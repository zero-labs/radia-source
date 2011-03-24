class RemoveOpenIdIdentityUrl < ActiveRecord::Migration
  def self.up
    remove_column :users, :identity_url
  end

  def self.down
    add_column :users, :identity_url, :string
  end
end
