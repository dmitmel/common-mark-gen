#!/usr/bin/env ruby
# encoding: UTF-8

# Command-line utility for generating HTML from Markdown file according to Github/CommonMark Markdown rules and using
# plugins/extensions.

require 'uri'
require 'net/http'

module OSDetector
    def self.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def self.unix?
        !self.windows?
    end

    def self.linux?
        self.unix? and not self.mac?
    end
end


def do_error(error_text)
    puts "common-mark-gen: error: #{error_text}"
    exit 1
end

def File.filename_without_extension(full_name)
    only_file = File.basename full_name, '.*'
    "#{File.dirname(full_name)}/#{only_file}"
end

def File.normalize_path(path)
    if path[0] == '~'
        return ENV[if OSDetector.unix? then 'HOME' else 'HOMEPATH' end] \
                + path[1..path.length] if path.length > 1
    else
        return path
    end
end

class String
    def add_space_before_each_line(space)
        lines = self.split "\n"
        lines.map! { |line| space + line }
        return lines.join "\n"
    end
end

module ArgumentsParser
    # private
    class ArgumentsParser_
        # public static
        def parse_arguments
            arguments = {}
            arguments['print_result'] = false
            arguments['all_in_one'] = false
            arguments['doc_style'] =
                "file://#{File.normalize_path '~/.common-mark-gen/github-markdown-view-style.css'}"
            arguments['code_style'] =
                "file://#{File.normalize_path '~/node_modules/highlight.js/styles/github-gist.css'}"

            # Printing help has bigger priority than printing version, so if there're options '-v' and '-h' -
            # help will be printed
            if need_to_print_help?
                puts make_help_message
                exit 0
            elsif need_to_print_version?
                puts '1.0'
                exit 0
            else
                i = 0
                while i < ARGV.length
                    arg = ARGV[i]

                    if arg == '-p' or arg == '--print-result'
                        arguments['print_result'] = true
                    elsif arg == '-1' or arg == '--all-in-one'
                        arguments['all_in_one'] = true
                    elsif arg == '--doc-style'
                        do_error 'argument --doc-style exactly takes a value' if i + 1 == ARGV.length
                        arguments['doc_style'] = ARGV[i += 1]
                    elsif arg == '--code-style'
                        do_error 'argument --code-style exactly takes a value' if i + 1 == ARGV.length
                        arguments['code_style'] = ARGV[i += 1]
                    elsif arg.start_with? '-'
                        do_error "unexpected option #{arg}"
                    else
                        # Parsing 2 positionals:
                        # 1. Required positional INPUT_FILE
                        # 2. Optional positional OUTPUT_FILE, defaults to "${input_file.name}.html"
                        if not arguments.include? 'input_file'
                            arguments['input_file'] = File.normalize_path arg
                        elsif not arguments.include? 'output_file'
                            arguments['output_file'] = File.normalize_path arg
                        else
                            do_error "Unexpected positional #{arg}" unless arg.start_with? '-'
                        end
                    end

                    i += 1
                end
            end

            do_error 'missing required positional INPUT_FILE' unless arguments['input_file']
            arguments['output_file'] = File.filename_without_extension(arguments['input_file']) +
                '.html' unless arguments.include? 'output_file'

            return arguments
        end

        # private static
        def make_help_message
            return "usage: common-mark-gen [-h] [-v] [-p] [-1] [--doc-style DOC_STYLE]
                       [--code-style CODE_STYLE] [--hljs-sources HIGHLIGHT_JS]
                       INPUT_FILE [OUTPUT_FILE]

Command-line utility for generating HTML from Markdown file according to Github/CommonMark
Markdown rules and using plugins/extensions.

positional arguments:
  INPUT_FILE            input file with Markdown
  OUTPUT_FILE           output file with HTML, defaults to
                        ${input_file.name}.html

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         show program's version number and exit
  -p, --print-result    print result when finished
  -1, --all-in-one      put dependency files to generated HTML file
  --doc-style DOC_STYLE
                        path to CSS file with styles for document (e.g.
                        headers, code boxes, etc), defaults to
                        file://~/.common-mark-gen/highlight.js/github-markdown-view-style.css
  --code-style CODE_STYLE
                        path to CSS file with styles for code highlighting
                        (used by highlight.js),defaults to
                        file://~/node_modules/highlight.js/styles/github-gist.css"
        end

        # private static
        def need_to_print_help?
            ARGV.include? '-h' or ARGV.include? '--help'
        end

        # private static
        def need_to_print_version?
            ARGV.include? '-v' or ARGV.include? '--version'
        end
    end

    private_constant :ArgumentsParser_

    def self.parse_arguments
        ArgumentsParser_.new.parse_arguments
    end
end

arguments = ArgumentsParser.parse_arguments

def get_file(url)
    file_protocol_matcher = url.match(/^file:\/\/(.+)$/)
    if url =~ /^file:\/\//
        return File.read(file_protocol_matcher.captures[0])
    else
        response = Net::HTTP.get_response(url)
        return response.body
    end
end

if arguments['all_in_one']
    html_dependencies = "<style>#{get_file(arguments['doc_style'])}</style>\n"
    html_dependencies += "<style>#{get_file(arguments['code_style'])}</style>\n"
else
    html_dependencies = "<link rel=\"stylesheet\" href=\"#{arguments['doc_style']}\">\n"
    html_dependencies += "<link rel=\"stylesheet\" href=\"#{arguments['code_style']}\">\n"
end

html = <<HTML
<!DOCTYPE html>

<html>
    <head>
        <meta charset="UTF-8">
    </head>

    <body class="markdown-body">
<!-- Page content mustn't be aligned, because of code blocks which will be moved. -->
#{`node #{File.dirname(__FILE__) + '/md-to-html.js'} #{arguments['input_file']}`}
    </body>

#{html_dependencies.add_space_before_each_line(' ' * 4)}
    <style>
        .markdown-body {
            padding: 10px 30px;
        }
    </style>
</html>
HTML

File.write(arguments['output_file'], html)
