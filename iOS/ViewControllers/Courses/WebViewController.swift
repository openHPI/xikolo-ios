//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class WebViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!

    weak var loginDelegate: LoginDelegate?

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

    override func removeFromParentViewController() {
        super.removeFromParentViewController()
        if self.webView.isLoading {
            self.webView.stopLoading()
            NetworkIndicator.end()
        }
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

                UserProfileHelper.shared.didLogin(withToken: token)
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: true)
                return false
            }

            return true
        }

        let userIsLoggedIn = UserProfileHelper.shared.isLoggedIn
        let headerIsPresent = request.allHTTPHeaderFields?.keys.contains(Routes.Header.authKey) ?? false

        if userIsLoggedIn, !headerIsPresent, let url = request.url, url.host == Routes.base.host {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = request
                    newRequest.allHTTPHeaderFields = NetworkHelper.requestHeaders(for: url)
                    self.webView.loadRequest(newRequest)
                }
            }

            return false
        }

        return true
    }
}

extension WebViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        guard let currentArea = delegate.currentArea else { return }

        if let slug = course.slug, currentArea == .discussions {
            self.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
        } else if currentArea == .recap {
            var urlComponents = URLComponents(url: Routes.recap, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "course_id", value: course.id)]
            self.url = urlComponents?.url
        }
    }

}
