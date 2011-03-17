class AddSimpleNameToProgram < ActiveRecord::Migration
  def self.up
    add_column :programs, :simple_name, :string

    Program.all.each do |p|
      p.update_attribute(:simple_name, Program.send(:name_janitor, p.name))
    end
  end

  def self.down
    remove_column :programs, :simple_name
  end
end
