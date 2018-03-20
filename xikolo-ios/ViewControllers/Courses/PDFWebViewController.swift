//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import UIKit

class PDFWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var cachedPdfPath: String?
    var urlToDownload: String!

    @IBOutlet var shareButton: UIBarButtonItem!
    
    @IBAction func sharePDF(_ sender: UIBarButtonItem) {
        guard let cachedPdfPath = self.cachedPdfPath, FileManager.default.fileExists(atPath: cachedPdfPath) else { return }
        let activityItem = NSData(contentsOfFile: cachedPdfPath).require(hint: "Cached PDF isn't a valid file")
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        self.webView.delegate = self
        savePdf().onSuccess { (pdfPath) in
            self.navigationItem.rightBarButtonItem = self.shareButton
            self.cachedPdfPath = pdfPath
            self.webView.loadRequest(URLRequest(url: URL(string: pdfPath).require()))
        }
    }

    func savePdf() -> Future<String, XikoloError> {
        let promise = Promise<String, XikoloError>()
        DispatchQueue.main.async {
            let fileManager = FileManager.default
            let path = NSTemporaryDirectory() + "temp.pdf"
            let pdfDoc = NSData(contentsOf: URL(string: self.urlToDownload)!)
            if fileManager.createFile(atPath: path, contents: pdfDoc as Data?, attributes: nil) {
                log.info("Downloaded PDF to temporary location with path: " + path)
                return promise.success(path)
            } else {
                log.error("Couldn't download pdf file with url: \(String(describing: self.urlToDownload))")
                return promise.failure(XikoloError.totallyUnknownError)
            }
        }
        return promise.future
    }

    // TODO remove temp file

}

extension PDFWebViewController: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NetworkIndicator.end()
    }

}

/*extension PDFWebViewController {
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        guard !self.webView.isLoading else { return }
        currentPdfPath = self.savePdf()
    }
}*/
