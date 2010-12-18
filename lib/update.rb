require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'
require "util"
require 'net/imap'


module Update

  include Util

  def fetch(uri_str, proxy=false,limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    response = nil
    if proxy
      response = Net::HTTP.Proxy("124.207.162.83","80").get_response(URI.parse(uri_str))
    else
      response = Net::HTTP.get_response(URI.parse(uri_str))
    end
    case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        fetch(response['location'], limit - 1)
      else
        response.error!
    end
  end

#
#  def do_quote
#    # create new updater
#    updater = QuoteUpdater.new({})
#    updater.start
#
#  end

  # takes a list of stock symbols, returns a map of the ones it can
  def get_quote(symbols)

    # create the map
    quotes = {}
    symbols.each {|symbol| quotes[symbol] = 0}


    begin
      url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{symbols.join("+")}&f=l1"
      puts url
      prices_str = fetch(url).body.split(" ")
      for n in 0..symbols.size-1
        quotes[symbols[n]] = prices_str[n].to_f
      end
    rescue => e
      puts symbol
      puts e.inspect
    end

    quotes.each_pair do |symbol,price|
      # try individual for each one of these
      if price.nil? || price == 0
        quotes[symbol] = get_price_from_google(symbol)
      end
    end

    return quotes

  end

  def get_price_from_google(symbol)


    begin
      url = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"
      puts url
      resp = fetch(url)
      body = resp.body
      body = body.gsub("\/\/", "").gsub("[", "").gsub("]", "")

      result = JSON.parse(body)
      price = result["l"]
      if !price.nil? && price.to_f
        return price.to_f
      end
    rescue => e
      puts symbol
      puts e.inspect
    end
#
#    # try a proxied google call
#    begin
#      url    = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"
#      puts url
#      resp   = fetch(url,true)
#      body   = resp.body
#      body   = body.gsub("\/\/", "").gsub("[", "").gsub("]", "")
#
#      result = JSON.parse(body)
#      price  = result["l"]
#      if !price.nil? && price.to_f
#        return price.to_f
#      end
#    rescue => e
#      puts symbol
#      puts e.inspect
#    end
    #return 0, this is the "unfound price""
    0
  end


  def get_and_save_symbol_from_email(email, source)
    entry = nil
    if source.address.include?(email[:from_address]) || email[:from_address].include?(source.address)
      text = email[:body]

      # get the symbol from the email
      symbols = get_symbols_from_text(email[:subject] + " " + strip_html(text))
      symbols.each do |symbol|
        if (!symbol.nil? && !is_bad_symbol?(symbol)) && !(tim_alert?(source) && email[:subject].downcase.include?("stocks to watch"))
          begin
            # check to see if this is a TIMalert watchlist, if so skip it

            puts "symbol found for #{source.address}: #{symbol}"

            #if this is a TIMALERT then do special action checking
            if tim_alert?(source)
              action = tim_alert_action(email)
            else
              action = nil
            end

            entry = Entry.new(:message_type=>type_email(),
                              :symbol=>symbol,
                              :sent_at=>email[:sent_at],
                              :subject=>email[:subject],
                              :body=>html2text(email[:body]),
                              :guid=>"#{email[:from_address]}:#{email[:sent_at].to_f.to_s}",
                              :action=>action
            )

            entry.source = source

            if entry.save
              @entry_count += 1
            end

          rescue => e
            put_error e
          end
        end
      end

      if symbols.nil? || symbols.size == 0
        puts "no symbols found for #{source.address}"
      end
    end

    entry
  end

  def do_symbol
    #    start with twitter
    sources = Source.all
    puts "Number of sources: #{sources.length}"

    @entry_count = 0

    for source in sources
      if !source.twitter.nil? && source.twitter.length > 1
        begin
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

              symbols = get_symbols_from_text rss_entry.description
              symbols.each do |symbol|
                if !symbol.nil? && !is_bad_symbol?(symbol)
                  puts "symbol: #{symbol}"

                  # we found a symbol, add it to the array
                  # get the date from rss
                  entry = Entry.new(:message_type=>type_twitter(), :symbol=>symbol, :sent_at=>rss_entry.pubDate, :url=>rss_entry.link, :guid=>rss_entry.guid, :action=>nil)
                  entry.source = source
                  if entry.save
                    @entry_count += 1
                  end

                end
              end

            end
          end
        rescue => e
          puts e.message
        end
      elsif !source.address.nil? && source.address.length > 2

        emails = get_emails source.address

        # check to see if a source is in any of the way unread emails
        emails.each do |email|
          get_and_save_symbol_from_email(email, source)
        end

      end
    end

    puts "entries added = #{@entry_count}"

  end



  def get_emails(source_address)

    puts "looking for emails from: #{source_address}"

    username = APP_CONFIG[:email_username]
    password = APP_CONFIG[:email_password]

    puts "looking in #{username} "

    emails = []

    $imap = Net::IMAP.new("imap.gmail.com", "993",true)
    $imap.login( username, password)

    # select the INBOX as the mailbox to work on
    $imap.select('INBOX')

    # retrieve all messages in the INBOX that
    # are not marked as DELETED (archived in Gmail-speak)
    $imap.search(["FROM",source_address,"NOT", "SEEN"]).each do |message_id|
      begin
        map = Hash.new

        # the mailbox the message was sent to
        # addresses take the form of {mailbox}@{host}
        envelope = $imap.fetch(message_id, 'ENVELOPE')
        envelope = envelope[0].attr['ENVELOPE']
        subject = envelope.subject
        mailbox = envelope.from[0].mailbox
        host = envelope.from[0].host

        from_address = "#{mailbox}@#{host}"
        body = $imap.fetch(message_id,'BODY[TEXT]')[0].attr['BODY[TEXT]']

        begin
          #split on charset
          matcher = body.match(/text\/html\; charset=ISO-\d\d\d\d-1(.*)--[\d\w]{2}/m)
          if matcher && matcher[1]
            body = matcher[1]
          end

        rescue => e
          puts e.backtrace
        end

        map[:from_address] = from_address
        map[:body] = body
        map[:uid] = message_id
        map[:subject] = subject
        map[:sent_at] = DateTime.parse(envelope.date)

        emails << map

      rescue => e
        puts e.inspect
      end

      $imap.store(message_id, "+FLAGS", [:Seen])

    end
    $imap.expunge

    $imap.logout

    puts "found #{emails.length} emails for #{source_address}"
    return emails

  end

end