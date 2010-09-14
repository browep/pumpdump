namespace :fix do

  #times are old fix them
  task :one => :environment do
    include Util

    # get all quotes that are more than 7 days old, delete them

    quotes = Quote.find(:all, :order=>"market_time", :conditions=>
              ["market_time > ? AND market_time < ?", DateTime.now - 7, DateTime.now - 1] )

    quotes.each do |quote|
      old_time = quote.market_time
      new_time = quote.market_time - (4/24.0 * 60 * 60 * 24)

#      quote.update_attribute("market_time", new_time)
      puts "just updated #{quote.id}, old_time:#{old_time.to_s} new_time:#{new_time.to_s}"
    end

  end
end
