class Entry < ActiveRecord::Base
  belongs_to :source
  attr_accessible :symbol,:sent_at,:guid,:url,:message_type,:subject,:body


  include Util
  def sent_at_with_zone
    if self.message_type == type_twitter
      add_hours(self.sent_at, 1)
    else
      add_hours(self.sent_at, 0)
    end
  end

  def self.find_last_seven_days
    find(:all, :order=>"sent_at", :conditions=>
              ["sent_at > ?", DateTime.now - 7])
  end

  def sent_at_on_graph
    if self.message_type == type_twitter
      add_hours(self.sent_at, -3)
    else
      add_hours(self.sent_at, -4)
    end

  end
end