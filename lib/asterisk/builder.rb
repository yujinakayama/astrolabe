# coding: utf-8

require 'asterisk/node'
require 'parser'

module Asterisk
  class Builder < Parser::Builders::Default
    def n(type, children, source_map)
      Node.new(type, children, location: source_map)
    end
  end
end
