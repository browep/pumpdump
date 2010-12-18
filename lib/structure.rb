require 'util'

class Structure
  include Util



  def initialize
    @entries = Array.new
    @logger = RAILS_DEFAULT_LOGGER

  end

  def add(symbol, source_id, date)
    @logger.debug "Adding #{symbol} for #{source_id.to_s} at #{date.to_s }"
    entry = {:symbol=>symbol, :source_id=>source_id, :date=>date}
    @entries.push(entry)
  end

  def debug_print
    for entry in @entries
      @logger.debug "#{entry[:symbol]}\t#{entry[:source_id]}\t#{entry[:date].to_s}"
    end
  end

  def sort
    @entries.sort! { |a,b| a[:date] <=> b[:date]}

  end

  def save
    # clear out all the old ones
    
  end

  

end