module Delayed
  class Job < ActiveRecord::Base
    def invoke_job
      logger.info "#{Time.now.utc} start delayed job #{payload_object.inspect}"
      payload_object.perform
      logger.info "#{Time.now.utc} ended delayed job #{payload_object.inspect}"
    end
  
    def log_exception(error)
      HoptoadNotifier.notify(error)
      logger.error "* [JOB] #{name} failed with #{error.class.name}: #{error.message} - #{attempts} failed attempts"
      logger.error(error)
    end
  end
end