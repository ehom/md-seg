require 'punkt-segmenter'

module Paragraph
  class Disassembler
    def self.perform(text)
      results = []
      tokenizer = Punkt::SentenceTokenizer.new(text)
      sentences = tokenizer.sentences_from_text(text, :output => :sentences_text)
      if sentences.length > 1
        sentences.each_with_index do |sentence, i|
          break if i > sentences.length - 2
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
end