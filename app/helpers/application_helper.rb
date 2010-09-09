# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   def format_datetime(date)
    date.strftime("%m/%d/%Y at %I:%M%p")
  end
end
