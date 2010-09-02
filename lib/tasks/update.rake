require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'


namespace :update do
  task :quote => :environment do
    # get all the symbols for the past 7 days
    last_seven_days_entries = Entry.find(:all,:order=>"sent_at",:conditions=>
      ["sent_at > ?",DateTime.now - 7])

    symbols = Set.new
    for entry in last_seven_days_entries
      symbols.add(entry.symbol)
    end

    puts "symbols: #{symbols.to_yaml}"

    # go over each symbol, try and get a quote
    symbols_added = []
    not_symbols_added = []
    for symbol in symbols
      begin
        url = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"
        body = fetch(url).body
        body = body.gsub("\/\/", "").gsub("[", "").gsub("]", "")

        result = JSON.parse(body)
        price = result["l"]

        quote = Quote.new({:symbol=>symbol, :last_price=>price, :market_time=>DateTime.now})
        if quote.save

          symbols_added.push(symbol)
        end


      rescue => e
        not_symbols_added.push(symbol)
        puts e.inspect
      end
    end

    puts "#{DateTime.now.to_s}: added #{symbols_added.size} quotes: #{symbols_added.join(", ")}"
    puts "not added: #{not_symbols_added.join(", ")}" unless not_symbols_added.size == 0
  end

  def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    response = Net::HTTP.get_response(URI.parse(uri_str))
    case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        fetch(response['location'], limit - 1)
      else
        response.error!
    end
  end

  task :symbol => :environment do
    include Util
    #    start with twitter
    sources = Source.all
    puts "Number of sources: #{sources.length}"

    structure = Structure.new

    @entry_count = 0

    for source in sources
      if !source.twitter.nil?
        twitter_name = source.twitter
        if source.twitter.include?("http://twitter")
          twitter_name = source.twitter.gsub("http:\/\/twitter.com\/", "")
        end

        rss_url = "http://api.twitter.com/1/statuses/user_timeline.rss?screen_name=#{twitter_name}"
        puts "Rss Url : #{rss_url}"
        rss = SimpleRSS.parse open(rss_url)

        for rss_entry in rss.entries
          # check to see if we already have this one
          if Entry.find(:first, :conditions=>{:guid=>rss_entry.guid}).nil?

            symbol = get_symbol_from_tweet rss_entry.description
            puts rss_entry.description
            if !symbol.nil? && !ignore_symbols().include?(symbol) 
              puts "symbol: #{symbol}"
              
              # we found a symbol, add it to the array
              # get the date from rss
              entry = Entry.new(:message_type=>type_twitter(), :symbol=>symbol, :sent_at=>rss_entry.pubDate, :url=>rss_entry.link, :guid=>rss_entry.guid)
              entry.source = source
              if entry.save
                @entry_count += 1
#                puts "Saved: #{entry.to_yaml.to_s}"
              end

            end
          end
        end

      end
    end

    structure.sort

    structure.debug_print
  end
end
