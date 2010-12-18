module ApplicationHelper

  def format_datetime(date)
    date.strftime("%m/%d/%Y at %I:%M%p")
  end

  def type_twitter
    0
  end

  def type_email
    1
  end

end
