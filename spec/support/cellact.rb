module Cellact
  class Sender
    def initialize(from, user, password, sender)
      @from, @user, @password, @sender = from, user, password, sender
    end

    def send_sms(mobile, text, parent, &block)
      return Sender.should_succeed?
    end

    def self.should_succeed?
      false
    end
  end
end