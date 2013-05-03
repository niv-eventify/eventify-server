module PaymentsHelper

  EVENT_TYPES_PACKAGE_DISPLAY = {
      :STANDARD => N_("Invitation Package"),
      :PREMIUM => N_("Premium Invitation Package"),
      :MOVIE => N_("Movie Invitation Package")
  }
  def emails_plan_package_display(event)
    EVENT_TYPES_PACKAGE_DISPLAY[EVENT_TYPES_KEYS[event.event_type]]
  end

  def emails_plans(event)
    plan = Eventify.const_get("#{EVENT_TYPES_KEYS[event.event_type]}_EMAILS_PLAN_PROPERTIES")
    current_locale == "he" ? plan.reverse : plan
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

  def payment_detail(title, amount, value)
    haml_tag(:div, :class => "settings-row") do
      haml_tag(:div, :class => "settings-info") do
        haml_tag(:strong, "#{amount} #{title}")
      end
      haml_tag(:em, value)
    end
  end

  def years_for_select
    (Time.now.utc.year..10.years.from_now.utc.year).to_a
  end

  def get_amount_or_zero
    resource.amount < 0 ? 0 : resource.amount.format_cents
  end
end
