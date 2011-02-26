class AddIndexOnSubscriberAddress < ActiveRecord::Migration
  def self.up
    add_index(:subscribers,:address)
  end

  def self.down
    remove_index(:subscribers,:address)
  end
end
