class Source < ActiveRecord::Base
  has_many :entries
  attr_accessible :name,:address,:twitter,:weight

end