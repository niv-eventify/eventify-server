module PaymentsHelper
  def emails_plans
    current_locale == "he" ? Eventify::EMAILS_PLAN_PROPERTIES.reverse : Eventify::EMAILS_PLAN_PROPERTIES
  end

  def current_plan?(plan)
    plan.first.include?(@invitations_count)
  end

  def li_class_for_email_plan(p, index)
    returning([]) do |res|
      res << "disabled" if p.first.last < @invitations_count
      res << "selected" if current_plan?(p)
    end.join(" ")
  end

  def emails_radio(plan, indx)
    opts = {:class => "radio", :id => "radio-quantity-#{indx}", :name => "payment[emails_plan]", :type => "radio", :value => plan.last.first}
    opts[:disabled] = "disabled" if plan.first.last < @invitations_count
    opts[:checked] = "checked"   if current_plan?(plan)
    haml_tag(:input, opts)
  end

  def payment_detail(title, value)
    haml_tag(:div, :class => "settings-row") do
      haml_tag(:div, :class => "settings-info") do
        haml_tag(:strong, title)
      end
      haml_tag(:em, value)
    end
  end

  def years_for_select
    (Time.now.utc.year..10.years.from_now.utc.year).to_a
  end
end
