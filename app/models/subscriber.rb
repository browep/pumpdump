class Subscriber < ActiveRecord::Base
  attr_accessible :address
  validates :address, :presence => true,
                     :length => {:minimum => 3, :maximum => 254},
                     :uniqueness => true,
                     :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}

end
