class Email < ActiveRecord::Base
  belongs_to :source
  attr_accessible :title,:body


end