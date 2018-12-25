require 'punkt-segmenter'

module Paragraph
  class Disassembler
    attr_accessor :add_brackets

    def initialize(add_brackets = false)
      @add_brackets = add_brackets
    end

    def perform(text)
      tokenizer = Punkt::SentenceTokenizer.new(text)
      sentences = tokenizer.sentences_from_text(text, :output => :sentences_text)

      if sentences.length >= 2
        results = sentences.take(sentences.length - 1).each_with_object([]) do |sentence, array|
          # puts "[#{i}] #{sentence}\n\n"
          array << mark_sentence(sentence)
        end
        results << mark_last_sentence(sentences)
      else
        # puts "single phrase: #{text}"
        [ text ]
      end
    end

    private

    def mark_sentence(text, add_brackets = false)
      text = "&#x00ab;%{sentence}&#x00bb;" % { sentence: text } if @add_brackets

      "<div class=\"%{name}\">%{sentence} </div>" % { name: SENTENCE_TAG, sentence: text }
    end

    def mark_last_sentence(sentences, add_brackets = false)
      text = sentences.last.chomp 
      text = "&#x00ab;%{sentence}&#x00bb;" % { sentence: text } if @add_brackets

      "<div class=\"%{name1} %{name2}\">%{sentence}</div>" %
        { name1: SENTENCE_TAG, name2: P_END_TAG, sentence: text }
    end
  end
end
