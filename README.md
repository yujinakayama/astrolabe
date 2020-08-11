[![Gem Version](https://badge.fury.io/rb/astrolabe.svg)](http://badge.fury.io/rb/astrolabe)
[![Dependency Status](https://gemnasium.com/yujinakayama/astrolabe.svg)](https://gemnasium.com/yujinakayama/astrolabe)
[![Build Status](https://travis-ci.org/yujinakayama/astrolabe.svg?branch=master&style=flat)](https://travis-ci.org/yujinakayama/astrolabe)
[![Coverage Status](https://coveralls.io/repos/yujinakayama/astrolabe/badge.svg?branch=master&service=github)](https://coveralls.io/github/yujinakayama/astrolabe?branch=master)
[![Code Climate](https://codeclimate.com/github/yujinakayama/astrolabe/badges/gpa.svg)](https://codeclimate.com/github/yujinakayama/astrolabe)

# Astrolabe

**Astrolabe** is an AST node library that provides an object-oriented way to handle AST by extending [Parser](https://github.com/whitequark/parser)'s node class.

## Installation

Add this line to your `Gemfile`:

```ruby
gem 'astrolabe'
```

And then execute:

```bash
$ bundle install
```

## Usage

You can generate an AST that consists of `Astrolabe::Node` by using `Astrolabe::Builder` along with `Parser`:

```ruby
require 'astrolabe/builder'
require 'parser/current'

source_buffer = Parser::Source::Buffer.new('(string)')
source_buffer.source = 'puts :foo'

ast_builder = Astrolabe::Builder.new
parser = Parser::CurrentRuby.new(ast_builder)

root_node = parser.parse(source_buffer)
root_node.class # => Astrolabe::Node
```

`Astrolabe::Node` is a subclass of [`Parser::AST::Node`](http://rubydoc.info/gems/parser/Parser/AST/Node).

## APIs

See these references for all the public APIs:

* [`Astrolabe::Node`](http://rubydoc.info/gems/astrolabe/Astrolabe/Node)
* [`Astrolabe::Builder`](http://rubydoc.info/gems/astrolabe/Astrolabe/Builder)

### Node Type Predicate Methods

These would be useful especially when combined with `Enumerable` methods (described below).

```ruby
node.send_type?    # Equivalent to: `node.type == :send`
node.op_asgn_type? # Equivalent to: `node.type == :op_asgn`

# Non-word characters (other than a-zA-Z0-9_) in type names are omitted.
node.defined_type? # Equivalent to: `node.type == :defined?`
```

### Access to Parent Node

```ruby
def method_taking_block?(node)
  return unless node.parent.block_type?
  node.parent.children.first.equal?(node)
end

block_node = parser.parse(buffer)
# (block
#   (send
#     (int 3) :times)
#   (args
#     (arg :i))
#   (send nil :do_something))

send_node, args_node, body_node = *block_node
method_taking_block?(send_node) # => true
```

### AST Traversal

These methods bring the power of `Enumerable` to AST.

Note that you may want to use [`Parser::AST::Processor`](http://rubydoc.info/gems/parser/Parser/AST/Processor)
if you don't need to track context of AST.

```ruby
# Iterate ancestor nodes in the order from parent to root.
node.each_ancestor { |ancestor_node| ... }

# This is different from `node.children.each { |child| ... }`
# which yields all children including non-node element.
node.each_child_node { |child_node| ... }

# These iteration methods can be chained by Enumerable methods.
# Find the first lvar node under the receiver node.
lvar_node = node.each_descendant.find(&:lvar_type?)

# Iterate the receiver node itself and the descendant nodes.
# This would be useful when you treat the receiver node as a root of tree
# and want to iterate all nodes in the tree.
ast.each_node { |node| ... }

# Yield only specific type nodes.
ast.each_node(:send) { |send_node| ... }
# This is equivalent to:
ast.each_node.select(&:send_type?).each { |send_node| ... }

# Yield only nodes matching any of the types.
ast.each_node(:send, :block) { |send_or_block_node| ... }
ast.each_node([:send, :block]) { |send_or_block_node| ... }
# These are equivalent to:
ast.each_node
  .select { |node| [:send, :block].include?(node.type) }
  .each { |send_or_block_node| ... }
```

## Projects using Astrolabe

* [Transpec](https://github.com/yujinakayama/transpec)

## Compatibility

Tested on MRI 2.2, 2.3, 2.4, 2.5, and JRuby 9000.

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
