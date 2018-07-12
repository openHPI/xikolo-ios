//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
import WebKit

class WebViewController: UIViewController {

    weak var loginDelegate: LoginDelegate?

    var webView: WKWebView!

    var url: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadURL()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeWebView()
        self.webView.navigationDelegate = self
        self.loadURL()
    }

    func initializeWebView() {
        // The manual initialization is necessary due to a bug in MSCoding in iOS 10
        self.webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }

    override func removeFromParentViewController() {
        super.removeFromParentViewController()
        if self.webView.isLoading {
            self.webView.stopLoading()
            NetworkIndicator.end()
        }
    }

    private func loadURL() {
        guard let url = self.url else { return }
        self.webView.load(NetworkHelper.request(for: url) as URLRequest)
    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        NetworkIndicator.start()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NetworkIndicator.end()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NetworkIndicator.end()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NetworkIndicator.end()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let documentURL = navigationAction.request.mainDocumentURL, documentURL.path ==  "/auth/app" {
            let urlComponents = URLComponents(url: documentURL, resolvingAgainstBaseURL: false)
            guard let queryItems = urlComponents?.queryItems else { return decisionHandler(.cancel) }

            if let tokenItem = queryItems.first(where: { $0.name == "token" }) {
                guard let token = tokenItem.value else { return decisionHandler(.cancel) }

                UserProfileHelper.shared.didLogin(withToken: token)
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: true)
                return decisionHandler(.cancel)
            }

            return decisionHandler(.allow)
        }

        let userIsLoggedIn = UserProfileHelper.shared.isLoggedIn
        let headerIsPresent = navigationAction.request.allHTTPHeaderFields?.keys.contains(Routes.Header.authKey) ?? false

        if userIsLoggedIn && !headerIsPresent {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = navigationAction.request
                    newRequest.allHTTPHeaderFields = NetworkHelper.requestHeaders
                    self.webView.load(newRequest)
                }
            }

            return decisionHandler(.cancel)
        }

        return decisionHandler(.allow)
    }
}

extension WebViewController: CourseContentViewController {

    func configure(for course: Course) {
        if let slug = course.slug {
            self.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
        }
    }

}
