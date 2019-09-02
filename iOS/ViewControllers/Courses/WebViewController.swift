//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class WebViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!

    weak var scrollDelegate: CourseAreaScrollDelegate?

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

    private lazy var backBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: R.image.arrowRoundBack(), style: .plain, target: self, action: #selector(goBack))
    }()

    weak var loginDelegate: LoginDelegate?

    var url: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadURL()
            }
        }
    }

    private var shouldShowToolbar: Bool {
        return self.courseArea == .discussions
    }

    private var webViewCanGoBack: Bool {
        // UIWebView.canGoBack returns false values. So we check for the initial URL instead.
        return self.webView.request?.url != self.url
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
        self.webView.scrollView.delegate = self

        self.progress.alpha = 0.0

        TrackingHelper.setCurrentTrackingCurrentAsCookie(with: self)
        self.loadURL()

        self.toolbarItems = [self.backBarButton]

        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveLinear, animations: {
            self.progress.alpha = CGFloat(1.0)
        }, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.shouldShowToolbar, !self.webView.isHidden {
            self.navigationController?.setToolbarHidden(false, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.shouldShowToolbar {
            self.navigationController?.setToolbarHidden(true, animated: animated)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            TrackingHelper.setCurrentTrackingCurrentAsCookie(with: self)
        }
    }

    override func removeFromParent() {
        super.removeFromParent()

        self.webView.delegate = nil
        if self.webView.isLoading {
            self.webView.stopLoading()
            NetworkIndicator.end()
        }
    }

    private func loadURL() {
        guard let url = self.url else { return }
        self.webView.loadRequest(NetworkHelper.request(for: url) as URLRequest)
    }

    private func updateToolbarButtons() {
        self.backBarButton.isEnabled = self.webViewCanGoBack
    }

    @objc private func goBack() {
        guard self.webViewCanGoBack else { return }
        self.webView.goBack()
        self.updateToolbarButtons()
    }

}

extension WebViewController: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        NetworkIndicator.start()

        if self.shouldShowToolbar {
            self.updateToolbarButtons()
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progress.isHidden = true
        self.webView.isHidden = false

        if self.shouldShowToolbar {
            self.updateToolbarButtons()
            if self.navigationController?.toolbar.isHidden ?? false {
                self.navigationController?.setToolbarHidden(false, animated: true)
            }
        }

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

extension WebViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

}

extension WebViewController: CourseAreaViewController {

    var area: CourseArea {
        return self.courseArea.require()
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        self.courseArea = area
        self.scrollDelegate = delegate

        if let slug = course.slug, area == .discussions {
            self.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
            TrackingHelper.createEvent(.visitedPinboard, inCourse: course, on: self)
        } else if area == .recap {
            var urlComponents = URLComponents(url: Routes.recap, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "course_id", value: course.id)]
            self.url = urlComponents?.url
            TrackingHelper.createEvent(.visitedRecap, inCourse: course, on: self)
        }
    }

}
