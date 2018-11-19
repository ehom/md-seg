
# https://www.gjtorikian.com/commonmarker/

require 'commonmarker'
require 'optparse'
require 'paragraph_factory'

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
    result = nil
    if node.to_commonmark.match(/^```/)
      result = node.to_commonmark + "\n"
    else
      result = "```\n#{node.to_plaintext}```\n"
    end
    result
  end

  def self.iterate_over_nodes(doc)
    @@paragraph = ParagraphFactory.new
    doc.each_with_object([]) do |node, output|
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

  def self.parse(args)
    program_name = File.basename($0)

    options = {}
    begin
      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{program_name} -i INPUT_FILE.md -o OUTPUT_FILE.md [OPTIONS]"
        opt.separator  ""
        opt.separator  "Options"

        opt.on("-i", "--input PATH", String,
               "Required GitHub Markdown filename") do |input_filename|
          options[:input_filename] = input_filename
        end

        opt.on("-o", "--output PATH", String,
               "Required Github Markdown output filename") do |output_filename|
          options[:output_filename] = output_filename
        end

        opt.on_tail("-h","--help","help") do
          puts opt_parser
          exit
        end
      end
      opt_parser.parse! args
    rescue StandardError => e
      puts "Error: %{message}" % {message: e.message}
    end

    puts opt_parser; exit unless options[:input_filename] && options[:output_filename]
    options
  end

  def self.process_file(filename)
    # open github markdown file
    array_of_lines = File.readlines(filename)

    doc = CommonMarker.render_doc(array_of_lines.join(''), :DEFAULT, [:autolink, :table, :tagfilter])

    lines = iterate_over_nodes(doc)
  end

  def self.main(args)

    options = parse args

    lines = process_file options[:input_filename]

    pp lines

    File.open(options[:output_filename], "w+") do |f|
      f.puts(lines)
    end
  end
end
