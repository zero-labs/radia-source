class ChangeRolesForDeclarativeAuthorization < ActiveRecord::Migration
  def self.up
    remove_column :roles, :authorizable_type
    remove_column :roles, :authorizable_id
    add_column :roles, :user_id, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :roles, :user_id
    add_column :roles, :authorizable_type, :string, :limit => 40
    add_column :roles, :authorizable_id, :integer
  end
end
