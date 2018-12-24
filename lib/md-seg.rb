require 'md-seg/document'
require 'md-seg/paragraph'
require 'optparse'

module MdSegApp
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
