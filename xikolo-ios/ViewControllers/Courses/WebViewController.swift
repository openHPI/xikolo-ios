//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

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
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            ])
        if #available(iOS 11, *) {
            let guide = self.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                self.webView.topAnchor.constraint(equalTo: guide.topAnchor),
                ])
        } else {
            NSLayoutConstraint.activate([
                self.webView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
                self.webView.heightAnchor.constraint(equalTo: bottomLayoutGuide.heightAnchor),
                ])
        }
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
        webView.load(NetworkHelper.request(for: url) as URLRequest)
    }

}

extension WebViewController: WKUIDelegate {

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

                UserProfileHelper.userId = nil
                UserProfileHelper.userToken = token
                UserProfileHelper.postLoginStateChange()
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: true)
                return decisionHandler(.cancel)
            }

            return decisionHandler(.allow)
        }

        let userIsLoggedIn = UserProfileHelper.isLoggedIn
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
