//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!

    weak var loginDelegate: AbstractLoginViewControllerDelegate?

    var url: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadURL()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        self.loadURL()
    }

    private func loadURL() {
        guard let url = self.url else { return }
        webView.loadRequest(NetworkHelper.request(for: url) as URLRequest)
    }

}

extension WebViewController: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if let documentURL = request.mainDocumentURL, documentURL.path ==  "/auth/app" {
            let urlComponents = URLComponents(url: documentURL, resolvingAgainstBaseURL: false)
            guard let queryItems = urlComponents?.queryItems else { return false }

            if let tokenItem = queryItems.first(where: { $0.name == "token" }) {
                guard let token = tokenItem.value else { return false }

                UserProfileHelper.userId = nil
                UserProfileHelper.userToken = token
                UserProfileHelper.postLoginStateChange()
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: true)
                return false
            }

            return true
        }

        let userIsLoggedIn = UserProfileHelper.isLoggedIn()
        let headerIsPresent = request.allHTTPHeaderFields?.keys.contains(Routes.Header.authKey) ?? false

        if userIsLoggedIn && !headerIsPresent {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = request
                    newRequest.allHTTPHeaderFields = NetworkHelper.requestHeaders
                    self.webView.loadRequest(newRequest)
                }
            }

            return false
        }

        return true
    }
}
