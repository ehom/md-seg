# https://www.gjtorikian.com/commonmarker/

require 'commonmarker'
require 'optparse'
require 'util/paragraph_factory'

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
    end

    def process
      # process_paragraphs should be under Markdown::Document
      lines = MdSegApp::process_paragraphs @document
    end
  end
end

module MdSegApp
  def self.handle_paragraph(node)
    text = node.to_commonmark(:DEFAULT, width = 1200)
    ParagraphFactory.disassemble text
  end

  def self.handle_html(node)
    text = node.to_commonmark
    assembled_paragraph = @@paragraph.assemble text
  end

  def self.handle_table(node)
    node.to_plaintext
  end

  def self.handle_as_commonmark(node)
    node.to_commonmark(:DEFAULT, width = 1200)
  end

  def self.handle_as_plaintext(node)
    node.to_plaintext
  end

  def self.handle_code_block(node)
    if node.to_commonmark.match(/^```/)
      result = node.to_commonmark + "\n"
    else
      result = "```\n#{node.to_plaintext}```\n"
    end
    result
  end

  def self.process_paragraphs(document)
    @@paragraph = ParagraphFactory.new
    document.each_with_object([]) do |node, output|
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
      when :header, :blockquote, :list
        output << handle_as_commonmark(node) << "\n"
      else
        puts "Other:[#{node.type}]"
      end
    end
  end

  def self.parse(arguments)
    options = {}

    option_parser = OptionParser.new do |option|
      option.banner = "Usage: %{program_name} -i INPUT_FILE.md -o OUTPUT_FILE.md [OPTIONS]" % { program_name: File.basename($0) }
      option.separator  ""
      option.separator  "Options"

      option.on("-i", "--input PATH", String,
                "Required GitHub Markdown filename") do |input_filename|
        options[:input_filename] = input_filename
      end

      option.on("-o", "--output PATH", String,
                "Required Github Markdown output filename") do |output_filename|
        options[:output_filename] = output_filename
      end

      option.on_tail("-h", "--help", "Show this message") do
        puts option_parser
        exit
      end
    end

    option_parser.parse! arguments

    raise "Input or output filename is missing." unless options[:input_filename] and options[:output_filename]

    options
  end

  def self.process_file(input_filename, output_filename)
    lines = Markdown::FileReader.new(input_filename).read

    new_lines = Markdown::Document.new(lines).process

    Markdown::FileWriter.new(output_filename).write new_lines

    new_lines
  end

  def self.main(arguments)
    begin
      options = parse arguments
      lines = process_file(options[:input_filename], options[:output_filename])
      pp lines
    rescue StandardError => e
      puts "Error: %{message}" % { message: e.message }
      puts e.backtrace
    end
  end
end
