require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'

require 'net/imap'
require 'update'
require 'update_quote'
require 'core'

namespace :update do
  task :quote => :environment do

    # create new updater
    Rails.logger.info "START updating quotes"
    start_time  = Time.now

    updater = QuoteUpdater.new({})
    updater.start

    end_time = Time.now

    time_delta = end_time - start_time
    Rails.logger.info "Updating quotes took #{time_delta} seconds"
    Rails.logger.info "END updating quotes"


  end


  task :symbol => :environment do
    include Update
    do_symbol
  end

  task :factor => :environment do
    include Core
    update_all_factors
  end

  task :cleanse_old => :environment do
    include Util
    sql = "DELETE from quotes where market_time < '#{time_to_sql_timestamp(add_days(DateTime.now, -40))}'"
    Rails.logger.info sql
    Quote.connection.execute(sql)
  end

  task :cleanse_factors => :environment do
    include Util
    sql = "TRUNCATE TABLE factors"
    Rails.logger.info sql
    Factor.connection.execute(sql)
  end

  task :regen_factors => :environment do
    include Update
    regen_factors
  end






end
