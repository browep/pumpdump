require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'
require 'httparty'

require 'net/imap'
require 'update'
require 'update_quote'
require 'core'

def top_charts
  include Util
  include Core
  i = 0
  top_symbols = Factor.top[0..3]
  top_symbols.to_a.each do |top_symbol|
    Rails.cache.write("symbol_#{i}", top_symbol[:symbol])
    Rails.cache.write("factor_#{i}", top_symbol[:factor])
    Rails.cache.write("count_#{i}", top_symbol[:count])
    Rails.cache.write("source_count_#{i}", top_symbol[:source_count])
    factors, min_price, prices = Entry.get_quotes(top_symbol[:symbol], 7)
    Rails.cache.write("factors_#{i}", factors)
    Rails.cache.write("prices_#{i}", prices)
    Rails.cache.write("min_price_#{i}", min_price)
    i+=1
  end
end

namespace :update do


  def divert_to_stdout
    if defined?(Rails) && (Rails.env == 'production')
      Rails.logger = Logger.new(STDOUT)
    end
  end
  

  task :quote => :environment do
#    divert_to_stdout
    # create new updater
    puts "START updating quotes"
    start_time  = Time.now

    updater = QuoteUpdater.new({})
    updater.start

    end_time = Time.now

    time_delta = end_time - start_time
    puts "Updating quotes took #{time_delta} seconds"
    puts "END updating quotes"


  end


  task :symbol => :environment do
    include Update
    do_symbol
  end

  task :factor => :environment do
    include Core
    update_all_factors
    top_charts()
  end

  task :cleanse_old => :environment do
    include Util
    ['quotes', 'entries', 'email_contents', 'factors'].each do |table_name|
      sql = "DELETE from #{table_name} where created_at < '#{time_to_sql_timestamp(add_days(DateTime.now, -40))}'"
      Rails.logger.info sql
      Quote.connection.execute(sql)
    end
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


  task :top_changed => :environment do
    include  Core

    top_symbol_from_cache = Rails.cache.read("top_symbol")
    Rails.logger.info "Top Symbol from cache: #{top_symbol_from_cache}"
    top_symbol_from_db = Factor.top[0][:symbol]
    Rails.logger.info "Top Symbol from search: #{top_symbol_from_db}"

    #if the cached one was nothing, set it to the top from db
    if top_symbol_from_cache.nil?
      Rails.logger.info("cached top symbol was nil, setting it to the db one : #{top_symbol_from_db}")
      Rails.cache.write("top_symbol",top_symbol_from_db)

    # we have one from the db and it doesnt equal the cached one
    elsif !top_symbol_from_db.nil? && top_symbol_from_db != top_symbol_from_cache
      Rails.logger.info("cached top symbol does not equal top from db, from cache:#{top_symbol_from_cache},  db:#{top_symbol_from_db}")
      Rails.cache.write("top_symbol",top_symbol_from_db)
      top_changed(top_symbol_from_db)
    elsif top_symbol_from_cache == top_symbol_from_db
      Rails.logger.info("from cache and db both equal #{top_symbol_from_cache} , do nothing")
    end




  end

  task :clear_top_changed => :environment do
    Rails.cache.write("top_symbol",nil)
  end

  task :set_top_changed => :environment do
    Rails.cache.write("top_symbol","AAPL")
  end

  task :send_aws_email => :environment do
    Subscriber.all.each do |subscriber|
      Rails.logger.info("sending email to #{subscriber.to_yaml}")
      AlertMailer.top_changed_email(subscriber, 'AAPL').deliver()
    end

  end

  task :top_charts => :environment do
    top_charts()
  end



end
