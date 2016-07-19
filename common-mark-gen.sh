#!/usr/bin/env bash

# Command-line utility for generating HTML from Markdown file according to Github/CommonMark Markdown rules and using
# plugins/extensions.

get_script_dir() {
    SCRIPT_PATH="${BASH_SOURCE[0]}";
    if [ -h "${SCRIPT_PATH}" ]; then
        while [ -h "${SCRIPT_PATH}" ]; do
            SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`
        done
    fi

    pushd . > /dev/null
    cd `dirname ${SCRIPT_PATH}` > /dev/null
    SCRIPT_PATH=`pwd`
    popd > /dev/null

    echo $SCRIPT_PATH
}

MD_TO_HTML_JS="$(get_script_dir)/md-to-html.js"
COMMON_MARK_GEN_HOME="$HOME/.common-mark-gen"
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
Command-line utility for generating HTML from Markdown file according to Github's/CommonMark's
Markdown rules and using plugins/extensions.

positional arguments:
  INPUT_FILE            input file with Markdown
  OUTPUT_FILE           output file with HTML, defaults to
                        \${name of INPUT_FILE without extension}.html

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         show program's version number and exit
  -p, --print-result    print result when finished
  -1, --one-file        put dependencies to generated HTML file
  --doc-style DOC_STYLE
                        path to CSS file with styles for document (e.g.
                        headers, code boxes, etc), defaults to
                        file://$COMMON_MARK_GEN_HOME/highlight.js/github-markdown.css
  --code-style CODE_STYLE
                        path to CSS file with styles for code highlighting
                        (used by highlight.js), defaults to
                        file://$COMMON_MARK_GEN_HOME/highlight.js/styles/github-gist.css
HELP
    exit
}

print_version() {
    echo "1.0"
    exit
}

print_error() {
    print_usage >&2
    echo "$0: $1" >&2
    exit 1
}

DOC_STYLE=$DEFAULT_DOC_STYLE
CODE_STYLE=$DEFAULT_CODE_STYLE

if [ $# == 0 ]; then
    print_usage >&2
    echo "try '$0 -h' or '$0 --help' for more information" >&2
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
        * ) if [[ "$1" =~ "-" ]]; then
                print_error "option $1: is unknown"
            else
                if [ -z "$INPUT_FILE" ]; then
                    INPUT_FILE="$1"
                    [ ! -f "$INPUT_FILE" ] && print_error "$INPUT_FILE: no such file or directory"
                    [ -d "$INPUT_FILE" ]   && print_error "$INPUT_FILE: is a directory"

                    OUTPUT_FILE="$(basename "$INPUT_FILE" | cut -d. -f1).html"
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
    echo "Downloading document style data..." >&2
    DOC_STYLE_DATA="$(curl $DOC_STYLE)"
    echo -e "\nDownloading code style data..." >&2
    CODE_STYLE_DATA="$(curl $CODE_STYLE)"

    here_doc_to_var HTML_DEPENDENCIES <<HTML_DEPENDENCIES
    <style>
$(echo "$DOC_STYLE_DATA" | sed 's/^/        /')
    </style>

    <style>
$(echo "$CODE_STYLE_DATA" | sed 's/^/        /')
    </style>
HTML_DEPENDENCIES
fi

MARKDOWN=$(node "$MD_TO_HTML_JS" "$INPUT_FILE")

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
    </style>
</html>
HTML

[ ! -z "$PRINT_RESULT" ] && echo "$HTML"

touch $OUTPUT_FILE
echo "$HTML" > $OUTPUT_FILE
