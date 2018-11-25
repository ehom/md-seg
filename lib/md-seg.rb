
# https://www.gjtorikian.com/commonmarker/

require 'commonmarker'
require 'optparse'
require 'util/paragraph_factory'

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

      option.on_tail("-h", "--help", "help") do
        puts option_parser
        exit
      end
    end

    option_parser.parse! arguments
    raise "Input or output filename is missing." unless options[:input_filename] and options[:output_filename]
    options
  end

  def self.process_file(filename)
    # open github markdown file
    begin
      array_of_lines = File.readlines(filename)
    rescue StandardError => e
      raise "Could not open \"#{filename}\". Reason: %{message}" % { message: e.message }
    end
    document = CommonMarker.render_doc(array_of_lines.join(''), :DEFAULT, [:autolink, :table, :tagfilter])
    lines = process_paragraphs(document)
  end

  def self.save_to_file(lines, filename)
    begin
      File.open(filename, "w+") do |file|
        file.puts(lines)
      end
    rescue StandardError => e
      raise "Could not write to \"%{filename}\". Reason: %{message}" % { message: e.message }
    end
  end

  def self.main(arguments)
    begin
      options = parse arguments
      lines = process_file(options[:input_filename])
      pp lines
      save_to_file(lines, options[:output_filename])
    rescue StandardError => e
      puts "Error: %{message}" % { message: e.message }
    end
  end
end
