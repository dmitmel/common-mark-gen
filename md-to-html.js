#!/usr/bin/env node

var hljs = require('highlight.js');

var md = require('markdown-it')({
    // Enable HTML
    html:         true,
    // CSS-class code language prefix for highlight.js
    langPrefix:   '',
    // Autoconvert URL-like text to links
    linkify:      true,
    // Enable some language-neutral replacement + quotes beautification
    typographer:  true,

    highlight: function (str, lang) {
        try {
            var highlightedCode = hljs.highlight(lang, str).value;

            // Removing newline char which was added by highlight.js to the end (if it was added)
            var lastIndex = highlightedCode.length - 1;
            var lastChar = highlightedCode[lastIndex];
            if (lastChar == '\n')
                highlightedCode = highlightedCode.substring(0, lastIndex);


            // Removing space char which was added by highlight.js to the start (if it was added)
            var firstChar = highlightedCode[0];
            if (firstChar == ' ')
                highlightedCode = highlightedCode.substring(1);

            return highlightedCode;
        } catch (__) {
            return ''; // use external default escaping
        }
    }
});

var plugins = {
    'sub': {},
    'sup': {},
    'abbr': {},
    'checkbox': {},
    'anchor': {
        permalink: true,
        permalinkSymbol: '<svg height="16" width="16"><path d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg>',
        permalinkBefore: true

    }
};

for (var pluginName in plugins) {
    var fullName = 'markdown-it-' + pluginName;
    var plugin = require(fullName);
    var pluginOptions = plugins[pluginName];
    md.use(plugin, pluginOptions);
}

fs = require('fs');
fs.readFile(process.argv[2], 'utf8', function (error, data) {
    if (error) {
        console.log(error);
        return;
    }
    var parsedMd = md.render(data);
    console.log(parsedMd);
});
