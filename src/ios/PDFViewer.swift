//
//  PDFViewer.swift
//  Highlights
//
//  Created by Guac on 1/7/24.
//

import PDFKit
import UIKit
import WebKit

@objc public class PDFViewer: NSObject {
    private var url = ""

    func loadPDFWithURL(url: String) {
//        if let document = PDFDocument(url: ) {
//            pdfView.document = document
//        }
    }

    private func createPDF(url: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextAuthor: "Guac"
        ]

        let format = UIGraphicsPDFRendererFormat()
        /// set the PDF's meta data
        format.documentInfo = pdfMetaData as [String: Any]

        /// PDF files use a coordinate system with 72 points per inch
        /// To create a document with a specific size, multiply the size in inches by 72 to get the number of points
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0

        /// Create a rectangle of the specified size
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        /// Create a PDFRenderer object with the dimensions of the rectangle, and the format containing the metadata
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        /// Create the PDF. The renderer creates a Core Graphics context that becomes the current context within
        /// the block. Drawing done in this context will appear on the PDF.
        let data = renderer.pdfData { (context) in
            /// Starts a new PDF page. This must be invoked before givign any other drawing instructions.
            context.beginPage()

            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
            ]

            let text = "Hello I am your first PDF"
            /// Draws the string to the current context.
            text.draw(at: CGPoint(x: 0, y:0), withAttributes: attributes)
        }

        return data
    }
}

private class PDFViewController: UIViewController {
    private let pdfView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
