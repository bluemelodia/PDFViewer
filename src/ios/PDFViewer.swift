import PDFKit
import UIKit
import WebKit

enum PDFLoadError: Error {
    case failedToLoadData(errorDescription: String)
    case invalidFileFormat(url: String)
    case invalidURL(url: String?)
}

@objc(PDFViewer) class PDFViewer: CDVPlugin {
    let wkWebView = WKWebView()

    /// Creates a PDF and displays the contents of hte provided URL.
    /// - Parameter command: an object that represents the calling context and arguments
    ///     from the Cordova webView
    /// - Returns: an object of type CDVPlugin result, so the Cordova bridge can execute
    ///     the success or error JavaScript callbacks. It will pass any return values from the native
    ///     code across the JavaScript - native bridge.
    @objc(openPDFWithURL:) func openPDFWithURL(command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult

        /// Extract the URL from the arguments passed in by JavaScript's exec function.
        if let url = command.arguments[0] as? String {
            do {
                try loadPDFWithURL(url: url)
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            } catch {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
            }

        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        }

        /// Tell the cordova app the result of executing the plugin function.
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }

    func loadPDFWithURL(url: String) throws {
        guard url.hasSuffix(".pdf") == true else {
            throw PDFLoadError.invalidFileFormat(url: url)
        }

        let pdfCreator = PDFViewController()
        pdfCreator.urlString = url
        self.viewController.addChild(pdfCreator)
        self.webView.addSubview(pdfCreator.view)
        pdfCreator.didMove(toParent: self.viewController)
    }

    func savePDF() {
        /// Create a print formatter object
        let printFormatter = wkWebView.viewPrintFormatter()
        /// Create renderer, which renders the print formatter's content on pages
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        /// Create a data object to store PDF data
        let pdfData = NSMutableData()
        /// Start a PDF graphics context. This makes it the current drawing context, and
        /// every drawing command after is captured and turned to PDF data.
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)

        /// Loop through the number of pages the renderer says it has, and on each
        /// iteration it starts a new PDF page.
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            /// draw the content of the page
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        /// Close PDF graphics context
        UIGraphicsEndPDFContext()
    }
}

private class PDFViewController: UIViewController {
    private var pdfView: PDFView?
    public var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView = PDFView(frame: self.view.bounds)

        if let pdfView {
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(pdfView)

            /// Fit content in PDFView
            pdfView.autoScales = true

            Task {
                guard let urlString,
                      let url = URL(string: urlString) else {
                    throw PDFLoadError.invalidURL(url: urlString)
                }

                do {
                    let (documentData, _) = try await URLSession.shared.data(from: url)
                    pdfView.document = PDFDocument(data: documentData)
                } catch {
                    throw PDFLoadError.failedToLoadData(errorDescription: error.localizedDescription)
                }
            }
        }
    }
}

