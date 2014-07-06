# coding: utf-8

module Astrolabe
  # @api private
  # http://semver.org/
  module Version
    MAJOR = 0
    MINOR = 5
    PATCH = 1

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
