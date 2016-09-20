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

        webView.loadRequest(NetworkHelper.getRequestForURL(url))
    }

}

extension WebViewController : UIWebViewDelegate {

    func webViewDidStartLoad(webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        NetworkIndicator.end()
    }
}
