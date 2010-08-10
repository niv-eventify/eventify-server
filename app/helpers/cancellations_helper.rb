module CancellationsHelper
  def emails_count
    count = @invited_stats[:email]
    n_("one guest", "%d guests", count) % count
  end

  def sms_count
    count = @invited_stats[:sms]
    n_("one guest", "%d guests", count) % count
  end
end
