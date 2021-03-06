require "velveteen/config"
require "velveteen/logger"
require "velveteen/message"
require "velveteen/worker"
require "velveteen/version"

module Velveteen
  class Error < StandardError; end
  class InvalidMessage < Error; end
  class WorkerTimeout < Error; end
end
