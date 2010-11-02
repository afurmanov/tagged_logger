class UserMailer < ActionMailer::Base
  default :from => "from@example.com"
  def index_email
    mail(:to => "to@example.com",  :subject => "list of users has been requested")
  end
end
