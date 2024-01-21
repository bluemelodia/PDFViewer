const exec = require('cordova/exec');

const pdfViewer = {};

pdfViewer.launch = function(successFn, errorFn) {
    exec(successFn, errorFn, 'PDFViewer', 'launch', [url]);
};

module.exports = pdfViewer;
