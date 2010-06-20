require 'dispatcher'
::Dispatcher.to_prepare do
  # InheritedResources::Base.send :include, InheritedResources::PaginatedCollectionHelper
  eval <<-EOF
    class Icalendar::Calendar
      def initialize()
        super("VCALENDAR")
      end
    end
  EOF
end
