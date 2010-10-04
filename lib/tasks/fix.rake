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


  task :remove_bad_symbols => :environment do
    include Util

    ignore_symbols.each do |symbol|
      entries = Entry.find_all_by_symbol(symbol)
      puts "removing for #{symbol}"
      entries.each do | entry|
        puts "destroying #{entry.id}"
        entry.destroy
      end
    end
  end

  task :upgrade_1 => :environment do
    include Util
    fixed_count = 0
    Entry.all.each do |entry|
      entry.update_attribute(:action, 0)
      fixed_count += 1
    end

    puts "fixed #{fixed_count} entries out of #{Entry.all.size}"

  end

  task :bad_symbols => :environment do
    include Util
    ignore_symbols.each do |symbol|
      bs = BadSymbol.new(:symbol=>symbol)
      if bs.save
        puts "just added #{bs.to_yaml}"
      end
    end


  end


end
