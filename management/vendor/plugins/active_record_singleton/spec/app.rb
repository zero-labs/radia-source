require 'active_record/singleton'

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :things, :force => true do |t|
      t.column "name", :string
    end
  end
end

class Thing < ActiveRecord::Base
  include ActiveRecord::Singleton
end