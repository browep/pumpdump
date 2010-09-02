require 'net/http'
require 'json'


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
    quotes_added = 0
    for symbol in symbols
      begin
        url = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"
        body = fetch(url).body
        body = body.gsub("\/\/", "").gsub("[", "").gsub("]", "")
        puts "body:#{body}"

        result = JSON.parse(body)
        puts "result:#{result.to_yaml}"
        price = result["l"]

        puts "#{symbol} : #{price}"
        quote = Quote.new({:symbol=>symbol, :last_price=>price, :market_time=>DateTime.now})
        if quote.save
          quotes_added += 1
        end


      rescue => e
        puts e.inspect
      end
    end

    puts "added #{quotes_added} quotes"
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
end
