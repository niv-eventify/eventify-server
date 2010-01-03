module GuestsHelper
  def new_guest_form
    form_remote_for(:guest, @guest ||= Guest.new, :builder => TableFormBuilder::Builder, 
      :url => event_guests_path(@event), :html => {:id => "new_guest"},
      :before => "jQuery('#adding_guest').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end
end
