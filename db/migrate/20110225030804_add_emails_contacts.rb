class AddEmailsContacts < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.timestamps
      t.string(:address,:null=>false,:unique=>true)
    end
  end

  def self.down
    drop_table :subscribers
  end
end
