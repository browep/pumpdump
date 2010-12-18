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

#  def time_to_sql_timestamp(time)
#    (time + 60 * 60 * @options[:offset]).strftime("%Y-%m-%d %H:%M:%S")
#  end

  task :cleanse_old => :environment do
    Quote.connection.execute("DELETE from quotes where market_time < #{time_to_sql_timestamp(add_days(DateTime.now,-30))}")
  end



end
