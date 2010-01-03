module GuestsHelper
  def new_guest_form
    form_remote_for(:guest, @guest ||= Guest.new, :builder => TableFormBuilder::Builder, 
      :url => event_guests_path(@event), :html => {:id => "new_guest"},
      :before => "jQuery('#adding_guest').attr('disabled', 'true')",
      :after => "$('#adding_guest').val('#{_("Add")}').attr('disabled', false);$('#new_guest').reset()") do |f|

      yield(f)

    end
  end
end
