class CreateEmailContents < ActiveRecord::Migration
  def self.up
    create_table :email_contents do |t|
      t.integer(:entry_id)
      t.string(:subject)
      t.text(:body)
      t.timestamps
    end
  end

  def self.down
    drop_table :email_contents
  end
end
