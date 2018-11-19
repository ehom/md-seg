require 'punkt-segmenter'
require 'nokogiri'

class ParagraphFactory
  SENTENCE_TAG = "paragraph-sentence".freeze
  P_END_TAG    = "paragraph-end".freeze

  def initialize
    @buffer = []
  end

  def sentence?(child)
    child.name == "div" and child.attribute('class').to_s.match?(SENTENCE_TAG)
  end

  def end_paragraph?(child)
    child.attribute('class').to_s.match?(P_END_TAG)
  end

  def assemble(str)
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

  def self.disassemble(text)
    results = []
    tokenizer = Punkt::SentenceTokenizer.new(text)
    sentences = tokenizer.sentences_from_text(text, :output => :sentences_text)
    if sentences.length > 1
      sentences.each_with_index do |sentence, i|
        break if i > sentences.length-2
        # puts "[#{i}] #{sentence}\n\n"
        results << "<div class=\"#{SENTENCE_TAG}\">#{sentence} </div>"
      end
      results << "<div class=\"#{SENTENCE_TAG} #{P_END_TAG}\">#{sentences.last.chomp} </div>"
    else
      # puts "single phrase: #{text}"
      results << text
    end
    # pp results
    results.join("\n\n")
  end
end
