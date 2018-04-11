//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import UIKit

class PDFWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var cachedPdfPath: URL!

    @IBOutlet var shareButton: UIBarButtonItem!
    
    @IBAction func sharePDF(_ sender: UIBarButtonItem) {
        guard let cachedPdfPath = self.cachedPdfPath, FileManager.default.fileExists(atPath: cachedPdfPath.absoluteString) else { return }
        let activityItem = NSData(contentsOfFile: cachedPdfPath.absoluteString).require(hint: "Cached PDF isn't a valid file")
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: cachedPdfPath)
        let data = try! Data.init(contentsOf: cachedPdfPath)
        webView.load(data, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL: cachedPdfPath.baseURL!)
    }

}
