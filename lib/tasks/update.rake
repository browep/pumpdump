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

  task :no_env do
    puts "no env"
  end

  task :env => :environment do
    puts "env"
  end


end
