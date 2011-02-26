require "rubygems"
require "thread"
require "util"
require "httparty"

module Core

  include Util

  def factor(symbol,curr_time=Time.now)
    sql = "SELECT entries.created_at,sources.weight,sources.id FROM `entries`,`sources` WHERE (entries.created_at < '#{time_to_sql_timestamp(add_hours(curr_time,5))}' ) AND (`entries`.`symbol` = '#{symbol}') AND entries.source_id = sources.id"
#    puts sql
    res = Entry.connection.execute(sql)

    # this will be a set of the sources
    sources = {}

    curr_sf = 0
    res.each do |entry|
      time = entry[0]
      pro_rate_factor   = (1/((curr_time - time + secs_in_day)/secs_in_day))
      calculated_factor = (entry[1].to_i * pro_rate_factor)
      curr_sf = curr_sf + calculated_factor
      if(sources[entry[2]].nil?)
        sources[entry[2]] = pro_rate_factor
      elsif sources[entry[2]] < pro_rate_factor
        sources[entry[2]] = pro_rate_factor
      end
    end

    #increase the factor for each different source, maybe by 20% for each one.
    sources.each do |key,value|
      curr_sf = curr_sf + (curr_sf * 0.2)
    end

    curr_sf.to_i

  end

  def update_factor(symbol,curr_time=Time.now)
    # get the factor
    _factor = factor(symbol,curr_time)
    # save that factor
    _factor = Factor.new({:symbol=>symbol,:factor=>_factor})
    _factor.created_at = curr_time
    if _factor.save
      return _factor
    end
    nil
  end

  def unique_symbols
    sql = "SELECT distinct symbol FROM `entries`"
    res = Entry.connection.execute(sql)
    symbols = []
    res.each {|result| symbols << result[0]}
    symbols
  end

  def update_all_factors
    q = Queue.new
    unique_symbols.each { |symbol| q.push(symbol) }

    puts "q:#{q.size}"

    time = Time.now

    factors = {}

    threads = []
    3.times do |num|
      threads << Thread.new do
        while !q.empty?
          begin
            symbol = q.pop
#            puts "#{num} starting #{symbol}"
            updated_factor = update_factor(symbol,time)
            if updated_factor
              puts "#{symbol}: \t#{updated_factor.factor}"
              factors[symbol] = updated_factor.factor
            else
              puts "#{symbol} had a problem"
            end
          rescue => e
            puts e.message
            puts e.backtrace
          end
        end
      end
    end

    threads.each do |t|
      t.join
    end

    factors = factors.sort {|a,b| a[1]<=>b[1]}
    puts factors.to_yaml


  end

  def do_migrations
    do_with_pagination(Entry, {:conditions=>["message_type = ?", 1]}, 10) do |entries|
      entries.each do |entry|
        if  entry.email_content.nil? && !entry.body.nil? && !entry.subject.nil?
          Rails.logger.info "Migrating entry:#{entry.id}"
          email_content = EmailContent.new(:body=>entry.body, :subject=>entry.subject)
          email_content.entry = entry
          email_content.save
          entry.update_attributes({:body=>nil,:subject=>nil}) 

        else
          Rails.logger.info "NOT Migrating entry:#{entry.id}"
        end
      end
    end
  end

  def top_changed(symbol)
    # tweet it out
    begin
      response = HTTParty.post("http://easytweet.heroku.com/api/status", {:headers=>{"X-TWITTER-ID"=>APP_CONFIG[:easy_tweet_id].to_s, "X-TWITTER-TOKEN"=>APP_CONFIG[:easy_tweet_token].to_s},
                                                                          :body=>"The stock with the highest factor has changed to $#{symbol}.  See it here http://thestockfactor.com"
      })
      Rails.logger.info("response from easy_tweet #{response.to_yaml}")
    rescue => e
      Rails.logger.error(e)
    end

    Subscriber.all.each do |subscriber|
      begin
        Rails.logger.info("sending email to #{subscriber.to_yaml}")
        AlertMailer.top_changed_email(subscriber, symbol).deliver()
      rescue => e
        Rails.logger.error(e)
      end
    end

    
  end

end