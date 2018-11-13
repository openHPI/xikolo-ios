//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class WebViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!

    private var courseArea: CourseArea?

    private lazy var progress: CircularProgressView = {
        let progress = CircularProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.lineWidth = 4
        progress.tintColor = Brand.default.colors.primary

        let progressValue: CGFloat? = nil
        progress.updateProgress(progressValue)
        return progress
    }()

    weak var loginDelegate: LoginDelegate?

    var url: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadURL()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.view.addSubview(self.progress)
        NSLayoutConstraint.activate([
            self.progress.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            self.progress.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor),
            self.progress.heightAnchor.constraint(equalToConstant: 50),
            self.progress.widthAnchor.constraint(equalTo: self.progress.heightAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.isHidden = true
        self.webView.delegate = self

        self.progress.alpha = 0.0

        self.loadURL()

        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveLinear, animations: {
            self.progress.alpha = CGFloat(1.0)
        }, completion: nil)
    }

    override func removeFromParent() {
        super.removeFromParent()
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
        self.progress.isHidden = true
        self.webView.isHidden = false
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NetworkIndicator.end()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let documentURL = Routes.isAppAuthenticationURL(for: request) {
            let urlComponents = URLComponents(url: documentURL, resolvingAgainstBaseURL: false)
            guard let queryItems = urlComponents?.queryItems else { return false }

            if let tokenItem = queryItems.first(where: { $0.name == "token" }) {
                guard let token = tokenItem.value else { return false }

                UserProfileHelper.shared.didLogin(withToken: token)
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled)
                return false
            }

            return true
        } else if let documentURL = Routes.isSingleSignOnCallbackURL(for: request) {
            let modifiedURL = Routes.addCallbackParameters(to: documentURL)
            guard modifiedURL != documentURL else { return true }

            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = request
                    newRequest.url = modifiedURL
                    self.webView.loadRequest(newRequest)
                }
            }

            return false
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

    var area: CourseArea {
        return self.courseArea.require()
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        self.courseArea = area

        if let slug = course.slug, area == .discussions {
            self.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
        } else if area == .recap {
            var urlComponents = URLComponents(url: Routes.recap, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "course_id", value: course.id)]
            self.url = urlComponents?.url
        }
    }

}
