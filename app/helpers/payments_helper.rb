module PaymentsHelper
  def emails_plans
    current_locale == "he" ? Eventify::EMAILS_PLAN_PROPERTIES.reverse : Eventify::EMAILS_PLAN_PROPERTIES
  end

  def current_plan?(plan)
    plan.first.include?(@guests_count)
  end

  def li_class_for_email_plan(p, index)
    returning([]) do |res|
      res << "disabled" if p.first.last < @guests_count
      res << "selected" if current_plan?(p)
      res << "first"    if index + 1 == Eventify::EMAILS_PLAN_PROPERTIES.size
    end.join(" ")
  end

  def emails_radio(plan, indx)
    opts = {:class => "radio", :id => "radio-quantity-#{indx}", :name => "payment[emails_plan]", :type => "radio", :value => plan.last.first}
    opts[:disabled] = "disabled" if plan.first.last < @guests_count
    opts[:checked] = "checked"   if current_plan?(plan)

    haml_tag(:input, opts)
  end
end
