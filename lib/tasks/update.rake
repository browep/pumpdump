require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'

require 'net/imap'


namespace :update do
  task :quote => :environment do
    include Update
    do_quote
  end


  task :symbol => :environment do
    include Update
    do_symbol
  end

  task :factor => :environment do
    include Core
    update_all_factors
  end


end
