# frozen_string_literal: true

require "rb_pipe_operator/version"

module RbPipeOperator
  class SourceCode
    def initialize(body)
      @body = body
    end

    def ast
      @ast ||= RubyVM::AbstractSyntaxTree.of(@body)
        .then { |node| node.children.last }
    end

    def source
      @source ||= RubyVM::InstructionSequence.of(@body)
        .then { |iseq| File.read(iseq.absolute_path) }
    end

    def to_s
      extracted = []
      source.each_line.with_index(1) do |line, i|
        if ast.first_lineno == i && ast.last_lineno == i
          extracted << line[ast.first_column..ast.last_column]
        elsif ast.first_lineno == i
          extracted << line[ast.first_column..]
        elsif ast.first_lineno < i && i < ast.last_lineno
          extracted << line
        elsif ast.last_lineno == i
          extracted << line[0..ast.last_column]
        end
      end
      extracted.join
    end
  end

  # TODO: rewrite to a code that uses RubyVM::AbstractSyntaxTree
  def self.enable(&block)
    code = SourceCode.new(block)
    buf = []
    code.to_s.each_line do |line|
      if line.include?('.|>')
        replaced = line.strip
          .split('.|>')
          .map.with_index { |node, i| i.zero? ? "(#{node})" : "(#{node}))" }
          .join('.then(&')
        buf << replaced
      else
        buf << line
      end
    end

    replaced_code = buf.join("\n")
    block.binding.eval(replaced_code)
  end
end
