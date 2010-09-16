require 'net/http'
require 'json'
require 'simple-rss'
require 'open-uri'

require 'net/imap'

module Update

  include Util

  def do_quote
    if during_trading_time?(DateTime.now().in_time_zone('Eastern Time (US & Canada)')) || APP_CONFIG[:observe_market_time] == false
      # get all the symbols for the past 7 days
      symbols = symbols_in_play()

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
    else
      puts "#{DateTime.now.to_s} not during trading hours."

    end
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

              symbol = get_symbol_from_text rss_entry.description
              if !symbol.nil? && !ignore_symbols().include?(symbol)
                puts "symbol: #{symbol}"

                # we found a symbol, add it to the array
                # get the date from rss
                entry = Entry.new(:message_type=>type_twitter(), :symbol=>symbol, :sent_at=>rss_entry.pubDate, :url=>rss_entry.link, :guid=>rss_entry.guid)
                entry.source = source
                if entry.save
                  @entry_count += 1
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
          if source.address.include?(email[:from_address]) || email[:from_address].include?(source.address)
            text = email[:body]
            symbol = get_symbol_from_text(strip_html(text))
            if !symbol.nil? && !ignore_symbols().include?(symbol)
              begin
                puts "symbol found for #{source.address}: #{symbol}"
                # we found a symbol, add it to the array
                # get the date from rss
                entry = Entry.new(:message_type=>type_email(),
                                  :symbol=>symbol,
                                  :sent_at=>email[:sent_at],
                                  :subject=>email[:subject],
                                  :body=>email[:body],
                                  :guid=>"#{email[:from_address]}:#{email[:sent_at].to_f.to_s}"
                )
                entry.source = source
                if entry.save
                  @entry_count += 1
                end
              rescue => e
                  put_error e
              end
            else
              "symbol not found for #{source.address}"
            end
          end
        end

      end
    end

    puts "entries added = #{@entry_count}"

  end


  def get_emails(source_address)

    puts "looking for emails from: #{source_address}"

    username = APP_CONFIG[:email_username]
    password = APP_CONFIG[:email_password]

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
        mailbox = envelope.from[0].mailbox
        host = envelope.from[0].host

        from_address = "#{mailbox}@#{host}"
        text = $imap.fetch(message_id, 'BODY[2]')[0].attr['BODY[2]']
        subject = envelope.subject

        map[:from_address] = from_address
        map[:body] = text
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