HoptoadNotifier.configure do |config|
  config.api_key = 'eventify-hoptoad-pass'
  config.environment_filters << 'rack-bug.*'
end
