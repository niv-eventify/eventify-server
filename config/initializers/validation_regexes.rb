class String
  EMAIL_REGEX = /^[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel|info|name)$/i
  EMAIL_INSIDE_REGEX = /[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel|info|name)/i
  PHONE_REGEX = /^\+\d{11,12}$|^0\d{9}$/
end