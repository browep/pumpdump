require "update"
require "util"
require 'eventmachine'

class QuoteUpdater 
  include Update

  def initialize(config)
    @thread_count = config[:threads] || 5
    @verbose = config[:verbose] || true
    @dry_run = config[:dry_run] || false
    @env = config[:env] || "development"
    @offset = config[:offset] || 4
    @market_offset = config[:market_offset] || 0
    @observe_market_time = APP_CONFIG[:observe_market_time]
    @queue= Queue.new
    @not_done   = Set.new

# get symbols in play

    if !should_run?
      return
    end

    entries = Entry.select("DISTINCT(symbol)").where("created_at > ?", add_days(DateTime.now, -7))
    entries.each { |entry|
      @queue << entry.symbol
      @not_done << entry.symbol
    }
    puts "getting quotes for #{@queue.to_yaml}"
    puts "queue size: #{@queue.size}"
    @orig_total = @queue.size
  end

  def should_run?

    market_time = DateTime.now
    if @observe_market_time && !during_trading_time?(market_time, true, APP_CONFIG[:holidays])
      Rails.logger.info "#{market_time} not during trading hours"
      return false
    elsif !@observe_market_time
      Rails.logger.info "not observing market time"
    end
    return true

  end

  def start

    if !should_run?
      return
    end

    EM.run {
      require 'em-http'

      while !@queue.empty?
        do_some_quotes(10)
      end
    }
    Rails.logger.info "EM has stopped running"
  end

  def finish(symbol,result)
    @not_done.delete(symbol)
    if @not_done.size < 10
      puts "orig size = #{@orig_total} , left = #{@not_done.to_a.join(",")}"
    end
    if @not_done.empty?
      puts "stopping EM"
      EventMachine::stop_event_loop
    end
  end

  def insert_quotes(quotes)
    begin
      quotes.each_pair do |symbol, price|
        quote = Quote.new(:symbol=>symbol, :last_price=>price, :market_time=>add_hours(Time.now, -1))
        Rails.logger.debug "inserting #{symbol}=>#{price}"
        if quote.save
          finish(symbol,true)
        else
          finish(symbol,false)
        end
      end
    rescue => e
      Rails.logger.debug e
      finish(symbol,false)
    end
  end

  def do_some_quotes(num_quotes)

    symbols = []
    num_quotes.times do
      symbols << @queue.pop unless @queue.empty?
    end
    # create the map
    quotes = {}
    symbols.each {|symbol| quotes[symbol] = 0}


    begin
      url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{symbols.join("+")}&f=l1"
      Rails.logger.debug url

      EM::HttpRequest.new(url).get.callback { |http|
#        Rails.logger.debug "response: #{http.response}"
        prices_str = http.response.split(" ")
        for n in 0..symbols.size-1
          quotes[symbols[n]] = prices_str[n].to_f
        end

        quotes.each_pair do |symbol, price|
          # try individual for each one of these
          if price.nil? || price == 0
            get_price_from_google(symbol)
          else
            insert_quotes({symbol=>price})
          end
        end

      }

    rescue => e
      Rails.logger.debug e.inspect
    end

  end

  def get_price_from_google(symbol)


    begin
      url = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"
      Rails.logger.debug url
      EM::HttpRequest.new(url).get.callback { |http|
        begin
          body   = http.response
          body   = body.gsub("\/\/", "").gsub("[", "").gsub("]", "")

          result = JSON.parse(body)
          price  = result["l"]
          if !price.nil? && price.to_f
            insert_quotes({symbol=>price})
          end
        rescue => e
          Rails.logger.debug "error trying to get #{symbol}"
          finish(symbol,false)
        end
      }

    rescue => e
      Rails.logger.debug symbol
      Rails.logger.debug e.inspect
    end
  end




end