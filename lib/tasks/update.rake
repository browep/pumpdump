require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'

require 'net/imap'


namespace :update do
  task :quote => :environment do
    include Update
    quote
  end


  task :symbol => :environment do
    include Update
    symbol
  end


end
