require 'nokogiri'

module Base
  class Assembler
    def initialize
      @buffer = []
    end

    def perform(str)
      nokogiri_object = Nokogiri::HTML.fragment(str)
      paragraph = nil
      if nokogiri_object.children.length > 0
        child = nokogiri_object.children.first

        if sentence?(child)
          @buffer << child.content.lstrip.chomp

          if end_paragraph?(child)
            paragraph = @buffer.join('')
            @buffer.clear
          end
          
        end
      end
      paragraph
    end

    private

    def sentence?(child)
      raise "Must be implemented"
    end

    def end_paragraph(child)
      raise "Must be implemented"
    end
  end
end

module Paragraph
  class Assembler < Base::Assembler
    def perform(str)
      super(str)
    end

    private

    def sentence?(child)
      child.name == "div" and child.attribute('class').to_s.match?(SENTENCE_TAG)
    end

    def end_paragraph?(child)
      child.attribute('class').to_s.match?(P_END_TAG)
    end
  end
end

module Blockquote
  class Assembler < Base::Assembler
    def initialize
    end

    def perform(text)
    end
  end
end