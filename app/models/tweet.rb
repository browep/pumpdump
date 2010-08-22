class Tweet < ActiveRecord::Base
  belongs_to :source
  attr_accessible :text

end