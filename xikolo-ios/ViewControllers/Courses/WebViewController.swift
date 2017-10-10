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

        if let documentURL = request.mainDocumentURL, documentURL.path ==  "/auth/app" {
           let urlComponents = URLComponents.init(url: documentURL, resolvingAgainstBaseURL: false)
            guard let queryItems = urlComponents?.queryItems else { return false }

            if let tokenItem = queryItems.first(where: { $0.name == "token"}) {
                guard let token = tokenItem.value else { return false }

                UserProfileHelper.userToken = token
                UserProfileHelper.postLoginStateChange()
                self.navigationController?.dismiss(animated: true) {
                    NetworkIndicator.end()
                }
                return false
            }

            return true
        }

        let userIsLoggedIn = UserProfileHelper.isLoggedIn()
        let headerIsPresent = request.allHTTPHeaderFields?.keys.contains(Routes.HTTP_AUTH_HEADER) ?? false

        if userIsLoggedIn && !headerIsPresent {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = request
                    newRequest.allHTTPHeaderFields = NetworkHelper.getRequestHeaders()
                    self.webView.loadRequest(newRequest)
                }
            }
            return false
        }

        return true
    }
}
