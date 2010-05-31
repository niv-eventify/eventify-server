module Delayed
  class Job < ActiveRecord::Base
    def invoke_job
      logger.info "#{Time.now.utc} start delayed job #{payload_object.inspect}"
      payload_object.perform
      logger.info "#{Time.now.utc} ended delayed job #{payload_object.inspect}"
    end
  end
end