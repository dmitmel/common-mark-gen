# common-mark-gen

> Command-line utility for generating pretty GitHub-like HTML from Markdown with CommonMark (http://commonmark.org/)
> syntax.

## Installation


```bash
curl https://raw.githubusercontent.com/dmitmel/common-mark-gen/master/common-mark-gen-installer.sh && bash common-mark-gen-installer.sh
```

## Usage

```nohighlight
common-mark-gen README.md README.html  # Will generate README.html
common-mark-gen README.md              # Will generate README.md.html
```

## Options

| Option                    | Description                                                                                                                                             |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-p`, `--print-result`    | print result                                                                                                                                            |
| `-1`, `--one-file`        | put all CSS to generated HTML file                                                                                                                      |
| `--doc-style DOC_STYLE`   | path to CSS file with styles for document (e.g. headers, code boxes, etc), defaults to file://$COMMON_MARK_GEN_HOME/highlight.js/github-markdown.css    |
| `--doc-style DOC_STYLE`   | path to CSS file with styles for code highlighting (used by highlight.js), defaults to file://$COMMON_MARK_GEN_HOME/highlight.js/styles/github-gist.css |
