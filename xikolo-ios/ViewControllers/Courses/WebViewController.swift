//
//  GenericWebViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var url: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self

        webView.loadRequest(NetworkHelper.getRequestForURL(url) as URLRequest)
    }

}

extension WebViewController : UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("Test#")
        print(request.debugDescription)
        if let dict = request.allHTTPHeaderFields {
            for entry in dict { print(entry.key + " : " + entry.value) }
        }
        if let body = request.httpBody {
            print(body)
        }
        return true

    }
}
