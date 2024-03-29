#!/usr/bin/env bash

# Command-line utility for generating pretty GitHub-like HTML from Markdown with CommonMark (http://commonmark.org/)
# syntax.

COMMON_MARK_GEN_HOME="$HOME/.common-mark-gen"
MD_TO_HTML_JS="$COMMON_MARK_GEN_HOME/md-to-html.js"
DEFAULT_DOC_STYLE="file://$COMMON_MARK_GEN_HOME/github-markdown.css"
DEFAULT_CODE_STYLE="file://$HOME/node_modules/highlight.js/styles/github-gist.css"

print_usage() {
    cat <<USAGE
usage: common-mark-gen [-h | --help] [-v | --version] [-p | --print-result] [-1 | --one-file]
                       [--doc-style DOC_STYLE] [--code-style CODE_STYLE]
                       INPUT_FILE [OUTPUT_FILE]
USAGE
}

print_help() {
    print_usage

    cat <<HELP
Command-line utility for generating pretty GitHub-like HTML from Markdown with
CommonMark http://commonmark.org/) syntax.

positional arguments:
  INPUT_FILE            input file with Markdown
  OUTPUT_FILE           output file with HTML, defaults to \$INPUT_FILE.html

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         show program's version number and exit
  -p, --print-result    print result
  -1, --one-file        put CSS to generated HTML file
  --doc-style DOC_STYLE
                        path to CSS file with styles for document (e.g.
                        headers, code boxes, etc), defaults to
                        $DEFAULT_DOC_STYLE
  --code-style CODE_STYLE
                        path to CSS file with styles for code highlighting
                        (used by highlight.js), defaults to
                        $DEFAULT_CODE_STYLE
HELP
    exit
}

print_version() {
    echo "1.0"
    exit
}

print_error() {
    print_usage >&2
    echo "common-mark-gen: $1" >&2
    exit 1
}

DOC_STYLE=$DEFAULT_DOC_STYLE
CODE_STYLE=$DEFAULT_CODE_STYLE

if [ $# == 0 ]; then
    print_usage >&2
    echo "try 'common-mark-gen -h' or 'common-mark-gen --help' for more information" >&2
    exit
fi

while true; do
    [ -z "$1" ] && break

    case "$1" in
        # Flags
        -h | --help )         print_help        ;;
        -v | --version )      print_version     ;;
        -p | --print-result ) PRINT_RESULT=true ;;
        -1 | --one-file )     ONE_FILE=true     ;;

        # Options
        --doc-style )  [ -z "$2" ] && print_error "option --doc-style: requires parameter"  || DOC_STYLE="$2";
                       shift ;;
        --code-style ) [ -z "$2" ] && print_error "option --code-style: requires parameter" || CODE_STYLE="$2";
                       shift ;;

        # Other arguments
        * ) if [[ "$1" =~ "^-" ]]; then
                print_error "option $1: is unknown"
            else
                if [ -z "$INPUT_FILE" ]; then
                    INPUT_FILE="$1"
                    [ ! -f "$INPUT_FILE" ] && print_error "$INPUT_FILE: no such file or directory"
                    [ -d "$INPUT_FILE" ]   && print_error "$INPUT_FILE: is a directory"
                elif [ -z "$OUTPUT_FILE" ]; then
                    OUTPUT_FILE="$1"
                else
                    print_error "$1: unexpected argument"
                fi
            fi ;;
    esac

    shift
done

[ -z "$INPUT_FILE" ] && print_error "no input file specified"
[ -z "$OUTPUT_FILE" ] && OUTPUT_FILE="$INPUT_FILE.html"

here_doc_to_var() {
    IFS='\n'
    read -r -d '' ${1} || true;
}

if [ -z "$ONE_FILE" ]; then
    here_doc_to_var HTML_DEPENDENCIES <<HTML_DEPENDENCIES
    <link rel="stylesheet" href="$DOC_STYLE">
    <link rel="stylesheet" href="$CODE_STYLE">
HTML_DEPENDENCIES
else
    DOC_STYLE_DATA="$(curl  --silent $DOC_STYLE)"
    [ "$?" != 0 ] && print_error "Failed to download document style!"
    CODE_STYLE_DATA="$(curl --silent $CODE_STYLE)"
    [ "$?" != 0 ] && print_error "Failed to download code style!"

    here_doc_to_var HTML_DEPENDENCIES <<HTML_DEPENDENCIES
    <style>
$(echo "$DOC_STYLE_DATA" | sed 's/^/        /')
    </style>

    <style>
$(echo "$CODE_STYLE_DATA" | sed 's/^/        /')
    </style>
HTML_DEPENDENCIES
fi

MARKDOWN="$(node "$MD_TO_HTML_JS" "$INPUT_FILE")"

here_doc_to_var HTML <<HTML
<!DOCTYPE html>

<html>
    <head>
        <meta charset="UTF-8">
    </head>

    <body class="markdown-body">
$MARKDOWN
    </body>

$(echo -e "$HTML_DEPENDENCIES")
    <style>
        .markdown-body {
            padding: 10px 30px;
        }

        .markdown-body code {
            padding-left: 0.4em;
            padding-right: 0.4em;
        }

        :before, :after {
            content: none !important;
        }

        .header-anchor {
            opacity: 0;
        }

        .header-anchor:link    { text-decoration: none !important; }
        .header-anchor:visited { text-decoration: none !important; }
        .header-anchor:hover   { text-decoration: none !important; }
        .header-anchor:active  { text-decoration: none !important; }

        h1:hover .header-anchor,
        h2:hover .header-anchor,
        h3:hover .header-anchor,
        h4:hover .header-anchor,
        h5:hover .header-anchor,
        h6:hover .header-anchor,
        .header-anchor:hover {
            opacity: 1;
        }
    </style>
</html>
HTML

[ ! -z "$PRINT_RESULT" ] && echo "$HTML"

touch $OUTPUT_FILE
echo "$HTML" > $OUTPUT_FILE
