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
            queryItems.forEach({ (queryItem) in
                if queryItem.name == "token" {
                    guard let token = queryItem.value  else { return }
                    UserProfileHelper.saveToken(token)
                    navigationController?.dismiss(animated: true, completion: nil)
                }
            })
            return true
        }

        let userIsLoggedIn = UserProfileHelper.isLoggedIn()
        let headerIsPresent = request.allHTTPHeaderFields?.keys.contains(Routes.HTTP_AUTH_HEADER) ?? false

        if let url = request.url?.absoluteString, userIsLoggedIn && !headerIsPresent {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    let newRequest = NetworkHelper.getRequestForURL(url)
                    self.webView.loadRequest(newRequest as URLRequest)
                }
            }
            return false
        }

        return true
    }
}
