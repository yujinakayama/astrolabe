# coding: utf-8

require 'parser'

module Asterisk
  # `Asterisk::Node` is a subclass of `Parser::AST::Node`. It provides an access to parent node and
  # an object-oriented way to handle AST with the power of `Enumerable`.
  class Node < Parser::AST::Node
    # @see http://rubydoc.info/gems/ast/AST/Node:initialize
    def initialize(type, children = [], properties = {})
      @mutable_attributes = {}

      # ::AST::Node#initialize freezes itself.
      super

      # #parent= would be invoked multiple times for a node because there are pending nodes while
      # constructing AST and they are replaced later.
      # For example, `lvar` and `send` type nodes are initially created as an `ident` type node and
      # fixed to each type later.
      # So, the #parent attribute needs to be mutable.
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

    # Returns the parent node, or `nil` if the receiver is a root node.
    #
    # @return [Node, nil] the parent node or `nil`
    def parent
      @mutable_attributes[:parent]
    end

    def parent=(node)
      @mutable_attributes[:parent] = node
    end

    protected :parent=

    # Calls the given block for each ancestor node in the order from parent to root.
    # If no block is given, an `Enumerator` is returned.
    #
    # @yieldparam [Node] node each ancestor node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_ancestor(&block)
      return to_enum(__method__) unless block_given?

      if parent
        yield parent
        parent.each_ancestor(&block)
      end

      self
    end

    # Calls the given block for each child node.
    # If no block is given, an `Enumerator` is returned.
    #
    # Note that this is different from `node.children.each { |n| ... }` which yields all children
    # including non-node element.
    #
    # @yieldparam [Node] node each child node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_child_node
      return to_enum(__method__) unless block_given?

      children.each do |child|
        next unless child.is_a?(Node)
        yield child
      end

      self
    end

    # Calls the given block for each descendant node with depth first order.
    # If no block is given, an `Enumerator` is returned.
    #
    # @yieldparam [Node] node each descendant node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_descendant(&block)
      return to_enum(__method__) unless block_given?

      each_child_node do |child_node|
        yield child_node
        child_node.each_descendant(&block)
      end
    end

    # Calls the given block for the receiver and each descendant node with depth first order.
    # If no block is given, an `Enumerator` is returned.
    #
    # This method is convenient when you treat the receiver node as a root of tree and want to
    # enumerate all nodes in the tree.
    #
    # @yieldparam [Node] node each node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each(&block)
      return to_enum(__method__) unless block_given?
      yield self
      each_descendant(&block)
    end

    # Returns whether the receiver is a root node or not.
    #
    # @return [Boolean] whether the receiver is a root node or not
    def root?
      parent.nil?
    end
  end
end
