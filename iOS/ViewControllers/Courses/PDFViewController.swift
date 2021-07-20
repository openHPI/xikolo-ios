//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import PDFKit
import UIKit
import WebKit

class PDFViewController: UIViewController {

    @IBOutlet private var shareButton: UIBarButtonItem!

    @available(iOS, obsoleted: 11.0)
    private var webView: WKWebView!

    // It's not possible to annotate stored properties with @available.
    // So we have to use a combination of type erased object and computed property
    // as long as we support iOS 10.
    private var pdfViewObject: AnyObject!

    @available(iOS 11, *)
    private var pdfView: PDFView {
        get {
            // swiftlint:disable:next force_cast
            return self.pdfViewObject as! PDFView
        }
        set {
            self.pdfViewObject = newValue
        }
    }

    private lazy var progress: CircularProgressView = {
        let progress = CircularProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.lineWidth = 4
        progress.gapWidth = 2
        progress.tintColor = Brand.default.colors.primary

        let progressValue: CGFloat? = nil
        progress.updateProgress(progressValue)
        return progress
    }()

    private lazy var downloadSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    private var tempPDFFile: TemporaryFile? {
        didSet {
            try? oldValue?.deleteDirectory()
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.tempPDFFile != nil ? self.shareButton : nil
            }
        }
    }

    private var currentDownload: URLSessionDownloadTask?

    private var filename: String?
    private var url: URL? {
        didSet {
            guard self.viewIfLoaded != nil else { return }
            guard let url = self.url else { return }
            self.loadPDF(for: url)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.view.addSubview(self.progress)
        NSLayoutConstraint.activate([
            self.progress.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            self.progress.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor),
            self.progress.heightAnchor.constraint(equalToConstant: 50),
            self.progress.widthAnchor.constraint(equalTo: self.progress.heightAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        if #available(iOS 11, *) {
            self.initializePDFView()
            self.pdfView.isHidden = true
        } else {
            self.initializeWebView()
            self.webView.isHidden = true
        }

        self.progress.alpha = 0.0

        if let url = self.url {
            self.loadPDF(for: url)
        }

        UIView.animate(withDuration: defaultAnimationDuration, delay: 0.5, options: .curveLinear) {
            self.progress.alpha = CGFloat(1.0)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.currentDownload?.cancel()
        try? self.tempPDFFile?.deleteDirectory()
    }

    func configure(for url: URL, filename: String?) {
        self.url = url
        self.filename = filename
    }

    @available(iOS, obsoleted: 11.0)
    func initializeWebView() {
        // The manual initialization is necessary due to a bug in NSCoding in iOS 10
        self.webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.webView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
     }

    @available(iOS 11, *)
    func initializePDFView() {
        self.pdfView = PDFView()
        self.view.addSubview(self.pdfView)
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.pdfView.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        if #available(iOS 12.0, *) {
            self.pdfView.pageShadowsEnabled = false
        }
    }

    private func loadPDF(for url: URL) {
        var request = URLRequest(url: url)
        request.setValue(Routes.Header.acceptPDF, forHTTPHeaderField: Routes.Header.acceptKey)
        for (key, value) in NetworkHelper.requestHeaders(for: url) {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = self.downloadSession.downloadTask(with: request)
        self.currentDownload = task
        task.resume()
    }

    @IBAction private func sharePDF(_ sender: UIBarButtonItem) {
        guard let fileURL = self.tempPDFFile?.fileURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

}

extension PDFViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.progress.updateProgress(1.0, animated: trueUnlessReduceMotionEnabled)
        }

        let filename: String = {
            if let filename = self.filename {
                return "\(filename).pdf"
            }

            if let suggestedFilename = downloadTask.response?.suggestedFilename {
                return suggestedFilename
            }

            if let requestURL = downloadTask.currentRequest?.url {
                return "\(requestURL.lastPathComponent).\(requestURL.pathExtension)"
            }

            return "file.pdf"
        }()

        do {
            let tmpFile = try TemporaryFile(creatingTempDirectoryForFilename: filename)
            try Data(contentsOf: location).write(to: tmpFile.fileURL)

            self.tempPDFFile = tmpFile

            DispatchQueue.main.async {
                if #available(iOS 11.0, *) {
                    self.pdfView.document = PDFDocument(url: tmpFile.fileURL)
                    self.progress.isHidden = true
                    self.pdfView.isHidden = false
                } else {
                    let request = URLRequest(url: tmpFile.fileURL)
                    self.webView.load(request)
                    self.progress.isHidden = true
                    self.webView.isHidden = false
                }
            }

            self.currentDownload = nil
        } catch {
            logger.error("Error processing PDF", error: error)
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let value = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progress.updateProgress(value, animated: trueUnlessReduceMotionEnabled)
        }
    }

}
