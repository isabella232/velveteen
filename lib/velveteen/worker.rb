require "json-schema"

module Velveteen
  class Worker
    attr_reader :message

    class << self
      attr_accessor :message_schema, :rate_limit_queue, :routing_key
    end

    def initialize(message:)
      @message = message

      maybe_validate_message!
    end

    def self.queue_name
      name
    end

    def rate_limited?
      !!self.class.rate_limit_queue
    end

    def rate_limit_queue
      self.class.rate_limit_queue
    end

    def queue_name
      self.class.queue_name
    end

    def routing_key
      self.class.routing_key
    end

    private

    def logger
      Velveteen.logger
    end

    def publish(payload, options = {})
      metadata = message.metadata.merge(options.delete(:metadata) || {})
      options[:headers] = options.fetch(:headers, {}).merge(metadata: metadata)
      Config.exchange.publish(payload, options)
    end

    def message_schema
      if self.class.message_schema
        File.expand_path(self.class.message_schema, Config.schema_directory)
      end
    end

    def maybe_validate_message!
      if message_schema
        errors = JSON::Validator.fully_validate(message_schema, message.data)

        if errors.any?
          raise InvalidMessage, errors.join("\n")
        end
      end
    end
  end
end
