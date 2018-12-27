require 'punkt-segmenter'

module Base
  class Disassembler
    def initialize(add_brackets = false)
      @adding_brackets = add_brackets
    end

    def perform(text)
      tokenizer = Punkt::SentenceTokenizer.new(text)
      sentences = tokenizer.sentences_from_text(text, :output => :sentences_text)

      if @adding_brackets
        bracketed_results = sentences.each_with_object([]) do |sentence, array|
          array << mark_sentence(sentence.chomp)
        end
        # pp bracketed_results
        bracketed_results
      else
        sentences
      end
    end

    def add_brackets(add_them = true)
      @adding_brackets = add_them
    end

    private

    def mark_sentence(text)
      "\u00ab%{sentence}\u00bb" % { sentence: text }
    end
  end
end

module Paragraph
  class Disassembler < Base::Disassembler
    def initialize(add_brackets = false)
      super(add_brackets)
    end

    def perform(text)
      sentences = super(text)
      if sentences.length >= 2
        add_tags_to sentences
      else
        [ text ]
      end
    end

    private

    def add_tags_to(sentences)
      results = sentences.take(sentences.length - 1).each_with_object([]) do |sentence, array|
        array << (tag_sentence sentence)
      end
      results << (tag_last_sentence sentences)
    end

    def tag_sentence(text)
      "<div class=\"%{name}\">%{sentence} </div>" % { name: SENTENCE_TAG, sentence: text }
    end

    def tag_last_sentence(sentences)
      "<div class=\"%{name1} %{name2}\">%{sentence}</div>" %
        { name1: SENTENCE_TAG, name2: P_END_TAG, sentence: sentences.last }
    end
  end
end

module Blockquote
  class Disassembler < Base::Disassembler
    def initialize
    end

    def perform(text)
    end
  end
end