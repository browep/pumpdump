#!/usr/bin/ruby -w
require "rubygems"
require "mysql"
require "yaml"
require "update"
require "util"
require "json"
require "thread"


def load_config
  raw_config = File.read("/usr/local/pumpdump/conf/app_config.yml")
  app_config = YAML.load(raw_config)
  app_config = app_config[ARGV[0]]

  app_config.each_pair do |k, v|
    app_config[k.to_sym] = v
  end

  raw_config = File.read("/usr/local/pumpdump/conf/database.yml")
  db_config = YAML.load(raw_config)
  db_config = db_config[ARGV[0]]


  db_config.each_pair do |k, v|
    db_config[k.to_sym] = v
  end

  return db_config,app_config
end

def time_to_sql_timestamp(time)
   time.strftime("%Y-%m-%d %H:%M:%S")
end

def do_symbol(dbh, symbol)
  begin
    puts "Fetching for #{symbol}"

    price = get_quote(symbol)
    if !price.nil?
      # insert this guy into the db
      market_time     = Time.now
      market_time_str = time_to_sql_timestamp(market_time)
      dbh.query("INSERT INTO `quotes` (`created_at`, `symbol`, `updated_at`, `last_price`, `exchange`, `market_time`) VALUES('#{market_time_str}', '#{symbol}', '#{market_time_str}', #{price}, NULL, '#{market_time_str}')")
    end
  rescue => e
    puts e
    puts e.backtrace
  end
end

include Update
include Util

db_config,app_config = load_config

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
ARGV[1].to_i.times do |num|
  threads << Thread.new do
    while !q.empty?
      symbol = q.pop
      puts "#{num}: -> #{symbol}"
      do_symbol(dbh, symbol)
    end
  end
end

sleep 0.1 until q.empty?

