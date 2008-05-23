class RenameUrlToUriForLiveSource < ActiveRecord::Migration
  def self.up
    rename_column :live_sources, :url, :uri
  end

  def self.down
    rename_column :live_sources, :uri, :url
  end
end
