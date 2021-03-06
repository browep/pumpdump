require 'digest/md5'

module Util
  # gets how many days ago it was, returns 0 if it was since the last market close
  def days_ago(date)
    puts ""
    puts "passed in date \t\t\t\t\t#{date.to_s}"
    # get the most recent market close
    curr_date = DateTime.now

    if(curr_date.hour() < 16)
      # we are before 4 pm
      # get one day before, set time to 4 o clock
      most_recent_close = DateTime.new(curr_date.year(), curr_date.month(), curr_date.day() -1 , 16)
    else
      # we are after 4 pm, set to today, time at 4pm
      most_recent_close = DateTime.new(curr_date.year(), curr_date.month(), curr_date.day(), 16)
    end

#    puts "Current Date #{curr_date.to_s}"
    puts "Most Recent Market Closing: \t#{most_recent_close.to_s}"

    elapsed_days = (most_recent_close - date).to_i + 1

    puts "Elapsed Days: #{elapsed_days}"

  end

  # DEPRECATED
#  def during_market_hours?(datetime,verbose=false)
##    if verbose
#      puts "day: #{datetime.day()}, hour: #{datetime.hour()}, minute: #{datetime.min()}"
##    end
#    # go through each market holiday, if it matches then not in market hours
#    holiday_str = APP_CONFIG[:holidays]
#    puts "holiday_str: #{holiday_str}"
#    if !holiday_str.nil?
#      holidays = holiday_str.split(",")
#      current_day_str = "#{datetime.year}#{datetime.month}#{datetime.day}"
#      puts "current day str: #{current_day_str}"
#      holidays.each do |holiday|
#        if holiday == current_day_str
#          puts "current date matches holiday #{holiday}, ending"
#          return false
#        end
#      end
#    end
#    puts "not in one of the holidays"
#    if (datetime.day() <= 5 && (datetime.hour() > 9 || (datetime.hour() == 9 && datetime.min() >= 30) && datetime.hour() < 16) )
#      return true
#    end
#    false
#  end

  def next_closest_market_open(datetime)

    puts "Passed in time:\t\t #{datetime.to_s}"
    # if this is during market hours, leave as is
    if(datetime.day() <= 5 && datetime.hour() > 9 && datetime.hour() < 16)

    else
      # get next closest market open

       # if this is after a close. add a day, set hour to 9
      if(datetime.hour() >= 16)
        datetime = DateTime.new(datetime.year(), datetime.month(), datetime.day() + 1, 9)

      else
        # else, this is in the morning, set time to 9
        datetime = DateTime.new(datetime.year(), datetime.month(), datetime.day(), 9)        

      end

    end
    puts "Closest market open: #{datetime.to_s}"

    return datetime


  end

  def get_symbols_from_text(text)
    symbols = Set.new
    matches = ("$"+ text +" ").scan(/[:\s\(\$\*#]([A-Z]{3,5})[,\.\)\s!\*]/)
    if(!matches.nil? && matches.size() > 0 )
      matches.each do |match|
        symbols << match[0]
      end
    end
    symbols.to_a
  end

  def type_twitter
    0
  end

  def type_email
    1
  end

  def strip_html(str)
    str.gsub(/<\/?[^>]*>/, "")
  end

  def seven_trading_days_back


  end

  def seven_trading_days_back_inner( date )
    case date.cwday()
      when 0
        days = []
    end


  end

  def during_trading_time?( datetime,verbose=false,holiday_str=nil)
    if verbose then
      Rails.logger.debug "day: #{datetime.cwday()}"
      Rails.logger.debug "hour: #{datetime.hour()}"
      Rails.logger.debug "minute: #{datetime.min()}"
      Rails.logger.debug "zone: #{datetime.zone()}"
    end

    Rails.logger.debug "holiday_str: #{holiday_str}"
    if !holiday_str.nil?
      holidays = holiday_str.split(",")
      current_day_str = "#{datetime.year}#{datetime.month}#{datetime.day}"
      Rails.logger.debug "current day str: #{current_day_str}"
      holidays.each do |holiday|
        if holiday == current_day_str
          Rails.logger.debug "current date matches holiday #{holiday}, ending"
          return false
        end
      end
    end
    Rails.logger.info "not in one of the holidays"

    datetime.cwday() <= 5 && ((datetime.hour() > 9 || (datetime.hour() == 9 && datetime.min() >= 45 ))  && (datetime.hour() < 16 || (datetime.hour() == 16 && datetime.min() <= 15)  ))

  end

  def ignore_symbols
    ["ONE","BIG","NOW","OTC","GET","TOP","NEW","BUY","FREE","PMI","MACD","EST","EPIC","MIME","YOU","WAS","HUGE",
     "HOT","DONT","MISS","THIS","HOD","VERY","HOT","NEWS", "WHOA", "VERY","NICE","AMEX","NONE","HOT","MEDIA","GOLD",
    "HERE","ALL","WOW","DONG","FENG","TON","GREAT","NOTE","TODAY","LLC"]
  end


  def symbols_in_play
    last_seven_days_entries = Entry.find_last_seven_days()

    symbols = Set.new
    for entry in last_seven_days_entries
      symbols.add(entry.symbol)
    end
    symbols
  end

  def with_zone(datetime)
    return datetime + 18000
  end

  def put_error(e)

    puts "Error: #{e.message}"
    puts e.backtrace
  end

  def add_days( datetime, days)
    add_hours(datetime, days*24 )
  end

  def add_hours( datetime, hours )
    if datetime.instance_of?(DateTime)
      return datetime + hours/24.0
    end
    datetime + ( hours * 3600)
  end

  def add_minutes(datetime,minutes)
    add_hours(datetime, minutes/60)
  end

  def tim_alert?(source)
    source.address.include?(APP_CONFIG[:timalert_address]) || APP_CONFIG[:timalert_address].include?(source.address)
  end


  def tim_alert_action(email)
    # if it contains the magic keywords
    subject = email[:subject].downcase

    short_words = ["shorted","reshorted"]

    covered_words = ["covered","got squeezed"]

    buy_words = ["bought"]

    sold_words = ["sold"]

    if !subject.nil?
      short_words.each do |word|
        if subject.include? word
          return Entry.SHORT
        end
      end
      covered_words.each do |word|
        if subject.include? word
          return Entry.COVER
        end
      end
      buy_words.each do |word|
        if subject.include? word
          return Entry.BUY
        end
      end
      sold_words.each do |word|
        if subject.include? word
          return Entry.SELL
        end
      end
    end

    Entry.SHORT

  end

  def is_bad_symbol?(symbol)
    found_symbols = BadSymbol.find_all_by_symbol(symbol,:conditions=>["verified = 1"])
    !found_symbols.nil? && found_symbols.size > 0
  end

  def html2text(html)
    html = html.gsub(/<style type='text\/css'>.*?<\/style>/, "")
    html = html.gsub("background:","invalid:")
    html = html.gsub("background-color:","invalid:")
    html = html.gsub("background-image:","invalid:")
  end

  def html2text_2(html)
    text = html.
            gsub(/(&nbsp;|\n|\s)+/im, ' ').squeeze(' ').strip.
            gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

    links = []
    linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>\s*/i
    while linkregex.match(text)
      links << $~[3]
      text.sub!(linkregex, "[#{links.size}]")
    end

    text = CGI.unescapeHTML(
            text.
                    gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
                    gsub(/<!--.*-->/m, '').
                    gsub(/<hr(| [^>]*)>/i, "___\n").
                    gsub(/<li(| [^>]*)>/i, "\n* ").
                    gsub(/<blockquote(| [^>]*)>/i, '> ').
                    gsub(/<(br)(| [^>]*)>/i, "\n").
                    gsub(/<(\/h[\d]+|p)(| [^>]*)>/i, "\n\n").
                    gsub(/<[^>]*>/, '')
    ).lstrip.gsub(/\n[ ]+/, "\n") + "\n"

    for i in (0...links.size).to_a
      text = text + "\n  [#{i+1}] <#{CGI.unescapeHTML(links[i])}>" unless links[i].nil?
    end
    links = nil
    text
  end

  def secs_in_day
    60 * 60 * 24
  end

  def time_to_sql_timestamp(time)
    time.strftime("%Y-%m-%d %H:%M:%S")
  end

  def do_with_pagination(model,query_args,page_size)
    offset = 0

    begin
      query_args.update({:offset=>offset,:limit=>page_size})
      results = model.all(query_args)
      yield(results)
      offset += page_size
    end while results.size == page_size

  end

  def sign_text(text)
    Digest::MD5.hexdigest("#{text}#{APP_CONFIG[:provider_secret_key]}")
  end

end