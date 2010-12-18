require 'util'

class Entry < ActiveRecord::Base
  belongs_to :source
  attr_accessible :symbol,:sent_at,:guid,:url,:message_type,:subject,:body,:action


  include Util
  def sent_at_with_zone
    if self.message_type == type_twitter
      add_hours(self.sent_at, 1)
    else
      add_hours(self.sent_at, 0)
    end
  end

  def self.find_last_seven_days
    find(:all,:select=>"sent_at,id,symbol,source_id", :order=>"sent_at", :conditions=>
              ["sent_at > ?", DateTime.now - 7])
  end

  def sent_at_on_graph
    if self.message_type == type_twitter
      add_hours(self.sent_at, -3)
    else
      add_hours(self.sent_at, -4)
    end

  end

  def self.BUY
    0
  end

  def self.SHORT
    1
  end

  def self.SELL
    2
  end

  def self.COVER
    3
  end

  def self.TWITTER
    0
  end

  def self.EMAIL
    1
  end

  def action_display_name
    if self.action == Entry.BUY
      "buy"
    elsif self.action == Entry.SHORT
      "short"
    elsif self.action == Entry.COVER
      "cover"
    elsif self.action == Entry.SELL
      "sell"
    end
  end

end