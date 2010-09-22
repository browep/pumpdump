require 'simple-rss'
require 'open-uri'

class AdminController < ApplicationController
  def update
#    start with twitter
    sources = Source.all
    logger.debug "Number of sources: #{sources.length}"

    structure = Structure.new

    @entry_count = 0

    for source in sources
      if !source.twitter.nil?
        twitter_name = source.twitter
        if source.twitter.include?("http://twitter")
          twitter_name = source.twitter.gsub("http:\/\/twitter.com\/","")
        end

        rss_url = "http://api.twitter.com/1/statuses/user_timeline.rss?screen_name=#{twitter_name}"
        logger.debug "Rss Url : #{rss_url}"
        rss = SimpleRSS.parse open(rss_url)

        for rss_entry in rss.entries
          # check to see if we already have this one
          if Entry.find(:first,:conditions=>{:guid=>rss_entry.guid}).nil?

            logger.debug rss_entry.description
            symbol = get_symbol_from_tweet rss_entry.description
            logger.debug "symbol: #{symbol}"
            if !symbol.nil?
              # we found a symbol, add it to the array
              # get the date from rss
              entry = Entry.new(:message_type=>type_twitter(),:symbol=>symbol,:sent_at=>rss_entry.pubDate,:url=>rss_entry.link,:guid=>rss_entry.guid)
              entry.source = source
              if entry.save
                @entry_count += 1
                logger.debug "Saved: #{entry.to_yaml.to_s}"
              end

            end
          end
        end

      end
    end

    structure.sort

    structure.debug_print
  end

  def test
    days_ago( DateTime.now )
    days_ago( DateTime.now + 1)
    days_ago( DateTime.now - 1)

    next_closest_market_open(DateTime.now)
  end

  def fake_data
    @symbol = params[:symbol]
    price = 25

    now = DateTime.now
    datetime = now -7

    @quotes = 0

    while datetime < now
      datetime = datetime.advance(:minutes => 2)
      if during_trading_time?(datetime)
        price += Float(rand(40))/100
        quote = Quote.new(:market_time=>datetime,:last_price=>price,:symbol=>@symbol)
        if quote.save
          @quotes += 1
        end
      end
    end


  end

  def set_auth_token
    @auth_token = params[:auth_token]
    session[:auth_token] = @auth_token
  end
end