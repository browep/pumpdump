class EmailContent < ActiveRecord::Base
  belongs_to :entry
  attr_accessible :body,:subject
end
