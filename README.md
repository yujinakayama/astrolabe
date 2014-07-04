[![Gem Version](http://img.shields.io/gem/v/astrolabe.svg)](http://badge.fury.io/rb/astrolabe)
[![Dependency Status](http://img.shields.io/gemnasium/yujinakayama/astrolabe.svg)](https://gemnasium.com/yujinakayama/astrolabe)
[![Build Status](https://travis-ci.org/yujinakayama/astrolabe.svg?branch=master)](https://travis-ci.org/yujinakayama/astrolabe)
[![Coverage Status](http://img.shields.io/coveralls/yujinakayama/astrolabe/master.svg)](https://coveralls.io/r/yujinakayama/astrolabe)
[![Code Climate](http://img.shields.io/codeclimate/github/yujinakayama/astrolabe.svg)](https://codeclimate.com/github/yujinakayama/astrolabe)

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

buffer = Parser::Source::Buffer.new('(string)')
buffer.source = 'puts :foo'

builder = Astrolabe::Builder.new
parser = Parser::CurrentRuby.new(builder)

root_node = parser.parse(buffer)
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
node.each_ancestor do |ancestor_node|
  p ancestor_node
end

# This is different from `node.children.each { |child| ... }`
# which yields all children including non-node element.
node.each_child_node do |child_node|
  p child_node
end

# Collect all lvar nodes under the receiver node.
lvar_nodes = node.each_descendant.select(&:lvar_type?)
```

## Compatibility

Tested on MRI 1.9, 2.0, 2.1, JRuby in 1.9 mode and Rubinius 2.0+.

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
