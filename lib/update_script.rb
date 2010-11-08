#!/usr/bin/ruby -w
require "rubygems"
require "mysql"
require "yaml"
require "update"
require "util"
require "json"
require "thread"
require 'optparse'

options  = {}

optparse = OptionParser.new do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner       = "Usage: optparse1.rb [options] file1 file2 ..."

  # Define the options, and what they do
  options[:verbose] = false
  opts.on('-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end

  options[:dryrun] = false
  opts.on('-d','--dry-run', 'Dry Run, dont actually commit to the db') do
    options[:dryrun] = true
  end

  options[:env] = "development"
  opts.on('-e','--environment ENV', 'Environment, development, test, production, default=development') do |environment|
    options[:env] = environment
  end

  options[:offset] =4
  begin
    opts.on('-o', '--offset OFFSET', 'Offset, how many hours are added to current timestamp') do |offset|
      options[:offset] = offset.to_i
    end
  end

  options[:market_offset] =0
  begin
    opts.on('-m', '--market_offset OFFSET', 'Offset, how many hours added to check for during market time') do |offset|
      options[:market_offset] = offset.to_i
    end
  end


  options[:threads] = 5
  begin
    opts.on('-t', '--threads THREADS', 'number of Threads') do |threads|
      options[:threads] = threads.to_i
    end
  end

end

optparse.parse!

puts "options:\n#{options.to_yaml}"

@options = options


def load_config
  raw_config = File.read("/usr/local/pumpdump/conf/app_config.yml")
  app_config = YAML.load(raw_config)
  app_config = app_config[@options[:env]]

  app_config.each_pair do |k, v|
    app_config[k.to_sym] = v
  end

  raw_config = File.read("/usr/local/pumpdump/conf/database.yml")
  db_config = YAML.load(raw_config)
  db_config = db_config[@options[:env]]


  db_config.each_pair do |k, v|
    db_config[k.to_sym] = v
  end

  return db_config,app_config
end

def time_to_sql_timestamp(time)
   (time + 60 * 60 * @options[:offset]).strftime("%Y-%m-%d %H:%M:%S")
end

def do_symbol(dbh, symbol)
  begin
    puts "Fetching for #{symbol}"

    price = get_quote(symbol)
    if !price.nil?
      # insert this guy into the db
      market_time     = Time.now
      market_time_str = time_to_sql_timestamp(market_time)
      insert_sql = "INSERT INTO `quotes` (`created_at`, `symbol`, `updated_at`, `last_price`, `exchange`, `market_time`) VALUES('#{market_time_str}', '#{symbol}', '#{market_time_str}', #{price}, 'script', '#{market_time_str}')"
      if !@options[:dryrun]
        insert_ret = dbh.query(insert_sql)
      else
        puts insert_sql
      end
    end
  rescue => e
    puts e
    puts e.backtrace
  end
end

include Update
include Util

db_config,app_config = load_config

# check to make sure we are in market time

market_time = add_hours(DateTime.now, @options[:market_offset])
puts "market time:#{market_time}"
if app_config[:observe_market_time] && !during_trading_time?(market_time,true)
  puts "not during market hours"
  exit(0)
end

# connect to the db
dbh = Mysql.real_connect("localhost", db_config[:username], db_config[:password],db_config[:database])

# get symbols in play
seven_days_ago = Time.now - 7* 60 * 60 * 24
seven_days_ago_str = time_to_sql_timestamp(seven_days_ago)

in_play_results = dbh.query("SELECT distinct symbol from entries where created_at > '#{seven_days_ago_str}'")

q = Queue.new

in_play_results.each do |symbol|
  q << symbol
end

threads = []
@options[:threads].to_i.times do |num|
  threads << Thread.new do
    while !q.empty?
      symbol = q.pop
      puts "#{num}: -> #{symbol}"
      do_symbol(dbh, symbol)
    end
  end
end

sleep 0.1 until q.empty?

