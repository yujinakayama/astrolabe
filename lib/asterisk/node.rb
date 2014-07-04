# coding: utf-8

require 'parser'

module Asterisk
  class Node < Parser::AST::Node
    def initialize(type, children = [], properties = {})
      @mutable_attributes = {}

      # ::AST::Node#initialize freezes itself.
      super

      each_child_node do |child_node|
        child_node.parent = self
      end
    end

    Parser::Meta::NODE_TYPES.each do |node_type|
      method_name = "#{node_type.to_s.gsub(/\W/, '')}_type?"
      define_method(method_name) do
        type == node_type
      end
    end

    def parent
      @mutable_attributes[:parent]
    end

    def parent=(node)
      @mutable_attributes[:parent] = node
    end

    protected :parent=

    def each_ancestor(&block)
      return to_enum(__method__) unless block_given?

      if parent
        yield parent
        parent.each_ancestor(&block)
      end

      self
    end

    def each_child_node
      return to_enum(__method__) unless block_given?

      children.each do |child|
        next unless child.is_a?(Node)
        yield child
      end

      self
    end

    def each_descendent(&block)
      return to_enum(__method__) unless block_given?

      each_child_node do |child_node|
        yield child_node
        child_node.each_descendent(&block)
      end
    end

    def each(&block)
      return to_enum(__method__) unless block_given?
      yield self
      each_descendent(&block)
    end
  end
end
