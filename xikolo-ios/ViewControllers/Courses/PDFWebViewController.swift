//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class PDFWebViewController: WebViewController {

    @IBAction func sharePDF(_ sender: UIBarButtonItem) {
        guard let cachedPdfPath = currentPdfPath, FileManager.default.fileExists(atPath: cachedPdfPath) else { return }
        let activityItem = NSData(contentsOfFile: cachedPdfPath).require(hint: "Cached PDF isn't a valid file")
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true)
    }

    var currentPdfPath: String?

    func savePdf() -> String {
        let fileManager = FileManager.default
        let path = NSTemporaryDirectory() + "temp.pdf"
        let pdfDoc = NSData(contentsOf: URL(string: url!)!)
        fileManager.createFile(atPath: path, contents: pdfDoc as Data?, attributes: nil)
        return path
    }

    // TODO remove temp file

}

extension PDFWebViewController {
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        guard !self.webView.isLoading else { return }
        currentPdfPath = self.savePdf()
    }
}
