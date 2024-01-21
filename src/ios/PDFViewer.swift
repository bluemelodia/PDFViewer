import PDFKit
import SwiftUI
import UIKit
import WebKit

enum PDFLoadError: Error {
    case failedToLoadData(errorDescription: String)
    case invalidFileFormat(url: String)
    case invalidURL(url: String?)
}

/// Example invocation:
///     window.viewer.openPDF("https://www.africau.edu/images/default/sample.pdf")
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

        let childVC = ViewController()
        childVC.urlString = url

        self.viewController.addChild(childVC)
        self.webView.addSubview(childVC.view)
        childVC.didMove(toParent: self.viewController)
    }
}

private class ViewController: UIViewController {
    let contentView = UIHostingController(rootView: ContentView())
    public var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        /// UIHostingController itself is not a view, so we can't just add the whole thing to the view sub-stack.
        /// Adding the hosting controller as a child to the view controller is needed to display the view.
        /// Additionally, you need to set up the constraints.
        addChild(contentView)
        view.addSubview(contentView.view)
        setupConstraints()
    }

    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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

