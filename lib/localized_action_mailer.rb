class LocalizedActionMailer < ActionMailer::Base
private
  def initialize_defaults(method_name)
    super
    @template = "#{I18n.locale}_#{method_name}"
  end 
end