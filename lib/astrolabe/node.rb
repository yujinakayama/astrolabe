# coding: utf-8

require 'parser'

module Astrolabe
  # `Astrolabe::Node` is a subclass of `Parser::AST::Node`. It provides an access to parent node and
  # an object-oriented way to handle AST with the power of `Enumerable`.
  #
  # Though not described in the auto-generated API documentation, it has predicate methods for every
  # node type. These methods would be useful especially when combined with `Enumerable` methods.
  #
  # @example
  #   node.send_type?    # Equivalent to: `node.type == :send`
  #   node.op_asgn_type? # Equivalent to: `node.type == :op_asgn`
  #
  #   # Non-word characters (other than a-zA-Z0-9_) in type names are omitted.
  #   node.defined_type? # Equivalent to: `node.type == :defined?`
  #
  #   # Collect all lvar nodes under the receiver node.
  #   lvar_nodes = node.each_descendant.select(&:lvar_type?)
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

    # Returns whether the receiver is a root node or not.
    #
    # @return [Boolean] whether the receiver is a root node or not
    def root?
      parent.nil?
    end

    # Calls the given block for each ancestor node in the order from parent to root.
    # If no block is given, an `Enumerator` is returned.
    #
    # @yieldparam [Node] node each ancestor node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_ancestor
      return to_enum(__method__) unless block_given?

      last_node = self

      while (current_node = last_node.parent)
        yield current_node
        last_node = current_node
      end

      self
    end

    # Calls the given block for each child node.
    # If no block is given, an `Enumerator` is returned.
    #
    # Note that this is different from `node.children.each { |child| ... }` which yields all
    # children including non-node element.
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

      children.each do |child|
        next unless child.is_a?(Node)
        yield child
        child.each_descendant(&block)
      end

      self
    end

    # Calls the given block for the receiver and each descendant node with depth first order.
    # If no block is given, an `Enumerator` is returned.
    #
    # This method would be useful when you treat the receiver node as a root of tree and want to
    # iterate all nodes in the tree.
    #
    # @yieldparam [Node] node each node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_node(&block)
      return to_enum(__method__) unless block_given?
      yield self
      each_descendant(&block)
    end
  end
end
