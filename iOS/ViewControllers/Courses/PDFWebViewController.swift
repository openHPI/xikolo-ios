//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit
import WebKit

class PDFWebViewController: UIViewController {

    @IBOutlet private var shareButton: UIBarButtonItem!

    var url: URL?

    private var webView: WKWebView?
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
        self.initializeWebView()
        self.navigationItem.rightBarButtonItem = nil

        if let url = self.url {
            self.loadPDF(for: url)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        try? self.tempPDFFile?.deleteDirectory()
    }

    private func initializeWebView() {
        // The manual initialization is necessary due to a bug in NSCoding in iOS 10
        let webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        self.webView = webView
    }

    private func loadPDF(for url: URL) {
        var request = URLRequest(url: url)
        request.setValue(Routes.Header.acceptPDF, forHTTPHeaderField: Routes.Header.acceptKey)
        for (key, value) in NetworkHelper.requestHeaders {
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
                    self.webView?.load(request)
                }
            } catch {
                log.error(error)
            }
        }

        task.resume()
    }

}
