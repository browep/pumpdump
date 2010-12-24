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
    @sleep_time = 7

# get symbols in play

    if !should_run?
      return
    end

    entries = Entry.select("DISTINCT(symbol)").where("created_at > ?", add_days(DateTime.now, -7)).order("rand()")
    entries.each { |entry|
      @queue << entry.symbol
      @not_done << entry.symbol
    }
#    puts "getting quotes for #{@queue.to_yaml}"
    Rails.logger.info "queue size: #{@queue.size}"
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


      while !@queue.empty?
        do_some_quotes(200)
        Rails.logger.debug "sleeping after doing another queue"
        sleep @sleep_time
      end
  end

  def finish(symbol)
    @not_done.delete(symbol)
    if @not_done.size < 50 || true
      Rails.logger.info "orig size = #{@orig_total} , left = #{@not_done.to_a.join(",")}"
    end
    if @not_done.empty?
      puts "Done."
    end
  end

  def insert_quote(symbol,price,time=Time.now)
    begin
        quote = Quote.new(:symbol=>symbol, :last_price=>price, :market_time=>add_hours(time, -1))
        Rails.logger.debug "inserting #{symbol}=>#{price} with time: #{time}"
        if !quote.save
          Rails.logger.error "had trouble inserting #{symbol} with price: #{price} with minutes offset: #{time}"
        end
    rescue => e
      Rails.logger.debug e
    end
    finish(symbol)

  end

  def get_multiple_from_google(symbols)


    symbols.each do |symbol|
      #check to see if we are the strict time adherence window, or ignoring market time

      get_price_from_google(symbol)
    end

  end

  def call_and_parse(symbols,extension="")
    begin
      (0..symbols.size-1).each do |i|
        symbols[i] = symbols[i] + extension
      end
      url = "http://query.yahooapis.com/v1/public/yql?q=select%20Symbol,LastTradePriceOnly,LastTradeTime%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22#{symbols.join(",")}%22)&env=store://datatables.org/alltableswithkeys&format=json"
#      url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{symbols.join("+")}&f=l1"
      Rails.logger.debug url

#      EM::HttpRequest.new(url).get.callback { |http|
#        body = http.response
      body = fetch(url).body
#        Rails.logger.debug "response: #{body}"
        begin
          result = JSON.parse(body)
        rescue => e
        end
#        Rails.logger.debug result.to_yaml
        result['query']['results']['quote'].each do |symbol_result|
          begin
            price  = symbol_result['LastTradePriceOnly'].to_f
            symbol = symbol_result['Symbol']
            if price != nil && price != 0
              # attempt to parse out the date
#              time = Time.parse(symbol_result['LastTradeTime'])
              time = Time.now - (15 * 60)
              insert_quote(clean_symbol(symbol), price, time)
              symbols.delete(symbol)
            end
          rescue => e
            Rails.logger.error "Problem with #{symbol_result}"
            Rails.logger.debug e.backtrace.join("\n")
          end
        end

        # whatever hasnt been removed, try with .PK extension
        if !symbols.empty?
          Rails.logger.debug "sleeping before making another call"
          sleep @sleep_time
          if extension == ""
            call_and_parse(symbols, ".PK")
          elsif extension == ".PK"
            (0..symbols.size-1).each{|i|symbols[i] = symbols[i].gsub(".PK","")}
            call_and_parse(symbols, ".OB")
          else
            # these are all the extension, we can't do anything about all this, finish these symbols
            Rails.logger.error "Couldnt find prices for #{symbols.join(",")}"
            symbols.each { |symbol| finish(clean_symbol(symbol)) }
          end
        end
#      }
    rescue => e
      Rails.logger.debug e.backtrace
      symbols.each { |symbol| finish(clean_symbol(symbol)) }
    end
  end

  def clean_symbol(symbol)
    symbol.gsub(".PK","").gsub(".OB","")
  end

  def do_some_quotes(num_quotes,extension="")

    symbols = []
    num_quotes.times do
      symbols << (@queue.pop + extension) unless @queue.empty?
    end
    # create the map
    quotes = {}
    symbols.each {|symbol| quotes[symbol] = 0}


    call_and_parse(symbols,"")

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
            Rails.logger.debug "google success with #{symbol}"
            insert_quote(symbol,price)
          end
        rescue => e
          Rails.logger.error "error trying to get #{symbol}"
#          Rails.logger.error e.inspect
          finish(symbol)
        end
      }

    rescue => e
      Rails.logger.debug symbol
      Rails.logger.debug e.inspect
    end
  end




end