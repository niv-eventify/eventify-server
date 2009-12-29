LiveValidations.use :jquery_validations, :default_valid_message => "", :validate_on_blur => true, 
  :validator_settings => {
    :errorElement => "p", :errorClass => "error-msg",
    :highlight => "function(element, errorClass){jQuery(element).parent('li').addClass('error')}",
    :unhighlight => "function(element, errorClass){jQuery(element).parent('li').removeClass('error')}",
    :errorPlacement => "function(error, element){jQuery(element).parents('.input-bg-alt').after(error);}"
  }
