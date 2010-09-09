class Entry < ActiveRecord::Base
  belongs_to :source
  attr_accessible :symbol,:sent_at,:guid,:url,:message_type

  def self.find_last_seven_days
    find(:all, :order=>"sent_at", :conditions=>
              ["sent_at > ?", DateTime.now - 7])
  end
end