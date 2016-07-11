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
            return hljs.highlight(lang, str).value;
        } catch (__) {
            return ''; // use external default escaping
        }
    }
});

var pluginNames = ['sub', 'sup', 'abbr', 'checkbox'];
for (var index in pluginNames) {
    var longName = 'markdown-it-' + pluginNames[index];
    var plugin = require(longName);
    md.use(plugin);
}

fs = require('fs');
fs.readFile(process.argv[2], 'utf8', function (error, data) {
    if (error)
        return console.log(error);
    var parsedMd = md.render(data);
    console.log(parsedMd);
});
