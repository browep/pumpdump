class Entry < ActiveRecord::Base
  belongs_to :source
  attr_accessible :symbol,:sent_at,:guid,:url,:message_type
end