module ActionController #:nodoc:
  class TestRequest < Request #:nodoc:
    private
    def initialize_default_values_with_www
      initialize_default_values_without_www
      @host = "www.test.host"
    end
    alias_method_chain :initialize_default_values, :www
  end
end