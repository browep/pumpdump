require 'parsedate'
require "thread"

module Core

  include Util

  def factor(symbol,curr_time=Time.now)
    puts
    sql = "SELECT entries.created_at,sources.weight FROM `entries`,`sources` WHERE (entries.created_at < '#{time_to_sql_timestamp(curr_time)}' ) AND (`entries`.`symbol` = '#{symbol}') AND entries.source_id = sources.id"
    res = Entry.connection.execute(sql)

    curr_sf = 0
    res.each do |entry|
      time = Time.local(*ParseDate.parsedate(entry[0]))
      calculated_factor = (entry[1].to_i * (1/((curr_time - time))))
#      puts "\t#{calculated_factor}"
      if calculated_factor > 1000
        this = 0
      end
      curr_sf = curr_sf + calculated_factor
    end


    (curr_sf * secs_in_day).to_i

  end

  def update_factor(symbol,curr_time=Time.now)
    # get the factor
    _factor = factor(symbol,curr_time)
    # save that factor
    _factor = Factor.new({:symbol=>symbol,:factor=>_factor})
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

    threads = []
    1.times do |num|
      threads << Thread.new do
        while !q.empty?
          begin
            symbol = q.pop
#            puts "#{num} starting #{symbol}"
            updated_factor = update_factor(symbol,time)
            if updated_factor
              puts "#{symbol}: \t#{updated_factor.factor}"
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
  end

end