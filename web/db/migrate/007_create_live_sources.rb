class CreateLiveSources < ActiveRecord::Migration
  def self.up
    create_table :live_sources do |t|
      t.belongs_to :settings
      t.string :url, :title
    end
  end

  def self.down
    drop_table :live_sources
  end
end
