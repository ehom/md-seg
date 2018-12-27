# https://www.gjtorikian.com/commonmarker/

require 'commonmarker'
require_relative 'paragraph'

module Markdown
  class FileReader
    def initialize(file_path)
      @file_path = file_path
    end

    def read
      begin
        array_of_lines = File.readlines(@file_path)
      rescue StandardError => e
        raise "Could not open \"%{filename}\". Reason: %{message}" % { filename: @file_path, message: e.message }
      end
    end
  end

  class FileWriter
    def initialize(file_path)
      @file_path = file_path
    end

    def write(lines)
      begin
        File.open(@file_path, "w+") do |file|
          file.puts(lines)
        end
      rescue StandardError => e
        raise "Could not write to \"%{filename}\". Reason: %{message}" % { filename: @file_path, message: e.message }
      end
    end
  end
  
  class Document
    def initialize(array_of_lines)
      @document = CommonMarker.render_doc(array_of_lines.join(''), :DEFAULT, [:autolink, :table, :tagfilter])
      @paragraph_assembler = Paragraph::Assembler.new
      @paragraph_disassembler = Paragraph::Disassembler.new
    end

    def process(add_brackets = false)
      @paragraph_disassembler.add_brackets(add_brackets)
      lines = process_paragraphs
    end

    private

    def handle_paragraph(node)
      text = node.to_commonmark(:DEFAULT, width = 1200)
      @paragraph_disassembler.perform(text).join("\n\n")
    end

    # we are only interested in 
    # <div class="paragraph-sentence"></div>
    # <div class="paragraph-end"></div>
    
    def handle_html(node)
      text = node.to_commonmark
      assembled_paragraph = @paragraph_assembler.perform text
    end

    def handle_table(node)
      node.to_plaintext
    end

    def handle_as_commonmark(node)
      node.to_commonmark(:DEFAULT, width = 1200)
    end

    def handle_as_plaintext(node)
      node.to_plaintext
    end

    def handle_code_block(node)
      if node.to_commonmark.match(/^```/)
        result = node.to_commonmark + "\n"
      else
        result = "```\n#{node.to_plaintext}```\n"
      end
      result
    end

    def process_paragraphs
      @document.each_with_object([]) do |node, output|
        case node.type
        when :paragraph
          output << handle_paragraph(node) << "\n"
        when :html
          assembled_paragraph = handle_html(node)
          output << assembled_paragraph << "\n" unless assembled_paragraph.nil?
        when :table
          output << handle_as_plaintext(node) << "\n"
        when :code_block
          output << handle_code_block(node) << "\n"
        when :blockquote
          # Todo: disassemble multi-sentence text body
          # output << handle_as_commonmark(node) << "\n"
          text = handle_as_commonmark(node)
          puts "blockquote: #{text}"
        when :header, :list
          output << handle_as_commonmark(node) << "\n"
        else
          puts "Other:[#{node.type}]"
        end
      end
    end
  end
end
