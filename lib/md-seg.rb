#!/usr/bin/env ruby

# https://www.gjtorikian.com/commonmarker/

require 'commonmarker'
require 'logger'
require 'optparse'

require 'helper'
require 'paragraph_factory'

module MdSegApp
  @@paragraph = []
  def self.iterate_over_nodes(doc)
    @@paragraph = ParagraphFactory.new
    logger = Helper::logger
    doc.each_with_object([]) do |node, output|
      if node.type == :paragraph
        text = node.to_commonmark(:DEFAULT, width = 1200)
        logger.info("[#{node.type}]\n#{text}")
        # puts "[#{node.type}]\n#{text}\n"
        logger.info("[original text in paragraph]: #{text}")
        output << ParagraphFactory.disassemble(text) << "\n"
      elsif node.type == :html
        logger.info("[#{node.type}]\n#{text}")
        text = node.to_commonmark
        assembled_paragraph = @@paragraph.assemble(text)
        output << assembled_paragraph << "\n" unless assembled_paragraph.nil?
      elsif node.type == :table
        logger.info("[#{node.type}]\n#{text}")
        logger.info(puts node.to_plaintext + "\n\n")
        output << node.to_plaintext + "\n"
      elsif node.type == :code_block
        logger.info("[#{node.type}]\n#{text}")
        logger.info node.to_commonmark
        if node.to_commonmark.match(/^```/)
          logger.info(node.to_commonmark + "\n\n")
          output << node.to_commonmark + "\n"
        else
          logger.info "```\n" + node.to_plaintext + "```\n\n"
          output << "```\n#{node.to_plaintext}```\n"
        end
      elsif node.type == :header || node.type == :blockquote || node.type === :list
        text = node.to_commonmark(:DEFAULT, width = 1200)
        logger.info("[#{node.type}]\n#{text}")
        output << text << "\n"
      else
        logger.info "Other: [#{node.type}]"
        logger.info node.to_plaintext + "\n"
        output << node.to_plaintext << "\n"
      end
    end
  end

  def self.main(argv)

    program_name = File.basename($0)

    options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{program_name} -i INPUT_FILE.md -o OUTPUT_FILE.md [OPTIONS]"
      opt.separator  ""
      opt.separator  "Options"

      opt.on("-i", "--input i_filename.md",
             "Required github markdown filename") do |input_filename|
        options[:input_filename] = input_filename
      end

      opt.on("-o", "--output o_filename.md",
             "Required github markdown filename") do |output_filename|
        options[:output_filename] = output_filename
      end

      opt.on("-d","--debug","debug") do
        # TODO
        # set logger switch here
      end

      opt.on("-h","--help","help") do
        puts opt_parser
        exit
      end
    end

    opt_parser.parse!(ARGV)

    raise OptionParser::MissingArgument if options[:input_filename].nil? || options[:output_filename].nil?

    # open github markdown file
    array_of_lines = File.readlines(options[:input_filename])

    doc = CommonMarker.render_doc(array_of_lines.join(''), :DEFAULT, [:autolink, :table, :tagfilter])

    lines = iterate_over_nodes(doc)

    pp lines

    File.open(options[:output_filename], "w+") do |f|
      f.puts(lines)
    end
  end
end
