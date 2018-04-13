//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import UIKit

class PDFWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var shareButton: UIBarButtonItem!

    var url: URL!
    private var tmpFile: TemporaryFile? = try? TemporaryFile(creatingTempDirectoryForFilename: "certificate.pdf")
    // TODO delete on disappes
    
    @IBAction func sharePDF(_ sender: UIBarButtonItem) {
        guard let fileURL = self.tmpFile?.fileURL else { return }
        guard let activityItem = try? Data(contentsOf: fileURL) else { return }
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tmp = self.tmpFile else {
            print("show error")
            return
        }

        var request = URLRequest(url: self.url)
        request.setValue(Routes.Header.acceptPDF, forHTTPHeaderField: Routes.Header.acceptKey)
        for (key, value) in NetworkHelper.requestHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                try data?.write(to: tmp.fileURL)
            } catch {
                print("error \(error)")
            }
            let request = URLRequest(url: tmp.fileURL)
            DispatchQueue.main.async {
                self.webView.loadRequest(request)
            }
        }

        task.resume()
    }

}
