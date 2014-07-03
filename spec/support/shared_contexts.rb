# coding: utf-8

shared_context 'AST', :ast do
  let(:root_node) do
    fail '#source must be defined with #let' unless respond_to?(:source)

    require 'asterisk/builder'
    require 'parser/current'

    buffer = Parser::Source::Buffer.new('(string)')
    buffer.source = source

    builder = Asterisk::Builder.new
    parser = Parser::CurrentRuby.new(builder)
    parser.parse(buffer)
  end
end
