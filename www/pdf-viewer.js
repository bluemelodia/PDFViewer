const exec = require('cordova/exec');

const pdfViewer = {};

pdfViewer.openPDF = function(url, successFn, errorFn) {
    if (!url) {
        throw new Error("A non-empty url is required.");
    }

    if (typeof url !== 'string') {
        throw new Error('A string url is required.');
    }

    exec(successFn, errorFn, 'PDFViewer', 'openPDFWithURL', [url]);
};

module.exports = pdfViewer;
