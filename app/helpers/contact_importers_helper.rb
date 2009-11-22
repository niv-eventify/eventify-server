module ContactImportersHelper
  DEFAULT_POLL_TIMEOUT = 3000

  def check_for_importer_status_js
    "setTimeout(function(){jQuery.ajax({url: '#{contact_importer_path(@contact_importer)}', type:'get', dataType:'script'});}, #{DEFAULT_POLL_TIMEOUT});"
  end
end
