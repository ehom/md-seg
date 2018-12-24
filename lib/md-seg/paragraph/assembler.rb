require 'nokogiri'

module Paragraph
  class Assembler
    def initialize
      @buffer = []
    end

    def perform(str)
      # puts("str: #{str}")
      nokogiri_object = Nokogiri::HTML.fragment(str)
      paragraph = nil
      if nokogiri_object.children.length > 0
        child = nokogiri_object.children.first

        if sentence?(child)
          @buffer << child.content.lstrip.chomp
          # puts "content: #{child.content}"

          if end_paragraph?(child)
            paragraph = @buffer.join('')
            @buffer.clear
            # puts "paragraph: #{paragraph}"
          end
        end
      end
      paragraph
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