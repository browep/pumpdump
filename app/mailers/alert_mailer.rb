class AlertMailer < ActionMailer::Base
  default :from => "'The Stock Factor' <thestockfactor@gmail.com>"
  layout 'email'
  include Util
  def top_changed_email(subscriber,symbol)
    @signature = sign_text(subscriber.id.to_s)
    @subscriber = subscriber
    @symbol = symbol
    mail(:to => subscriber.address,
         :subject => "#{symbol} is now the symbol with the highest stock factor!")
  end
end
