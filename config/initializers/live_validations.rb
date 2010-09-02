LiveValidations.use :jquery_validations, :default_valid_message => "", :validate_on_blur => true, 
  :validator_settings => {
    :errorElement => "p", :errorClass => "error-msg",
    :highlight => "function(element, errorClass){jQuery(element).parents('li:first').addClass('error')}",
    :unhighlight => "function(element, errorClass){jQuery(element).parents('li:first').removeClass('error')}",
    :errorPlacement => "function(error, element){jQuery(element).parents('.input-bg-alt,.textarea-bg').after(error);jQuery('body').css('cursor', 'default');}"
  }
