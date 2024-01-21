import PDFKit
import SwiftUI
import UIKit
import WebKit

/// Example invocation:
///     window.viewer.launch()
@objc(PDFViewer) class PDFViewer: CDVPlugin {
    let wkWebView = WKWebView()

    /// Launches the PDF app.
    /// - Parameter command: an object that represents the calling context and arguments
    ///     from the Cordova webView
    /// - Returns: an object of type CDVPlugin result, so the Cordova bridge can execute
    ///     the success or error JavaScript callbacks. It will pass any return values from the native
    ///     code across the JavaScript - native bridge.
    @objc(launch:) func launch(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)

        Task { @MainActor in
            launch()
        }

        /// Tell the cordova app the result of executing the plugin function.
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }

    func launch() {
        let childVC = ViewController()

        self.viewController.addChild(childVC)
        self.webView.addSubview(childVC.view)
        childVC.didMove(toParent: self.viewController)
    }
}

private class ViewController: UIViewController {
    let contentView = UIHostingController(rootView: ContentView())

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

/*
 enum PDFLoadError: Error {
     case failedToLoadData(errorDescription: String)
     case invalidFileFormat(url: String)
     case invalidURL(url: String?)
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
*/
