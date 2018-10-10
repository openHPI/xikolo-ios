//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class PDFWebViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet private var shareButton: UIBarButtonItem!

    var url: URL?

    private var tempPDFFile: TemporaryFile? {
        didSet {
            try? oldValue?.deleteDirectory()
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.tempPDFFile != nil ? self.shareButton : nil
            }
        }
    }

    @IBAction func sharePDF(_ sender: UIBarButtonItem) {
        guard let fileURL = self.tempPDFFile?.fileURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil

        if let url = self.url {
            self.loadPDF(for: url)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        try? self.tempPDFFile?.deleteDirectory()
    }

    private func loadPDF(for url: URL) {
        var request = URLRequest(url: url)
        request.setValue(Routes.Header.acceptPDF, forHTTPHeaderField: Routes.Header.acceptKey)
        for (key, value) in NetworkHelper.requestHeaders(for: url) {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let filename = response?.suggestedFilename ?? "\(url.lastPathComponent).pdf"

            do {
                let tmpFile = try TemporaryFile(creatingTempDirectoryForFilename: filename)
                try data?.write(to: tmpFile.fileURL)

                self.tempPDFFile = tmpFile
                let request = URLRequest(url: tmpFile.fileURL)
                DispatchQueue.main.async {
                    self.webView.loadRequest(request)
                }
            } catch {
                log.error(error)
            }
        }

        task.resume()
    }

}
