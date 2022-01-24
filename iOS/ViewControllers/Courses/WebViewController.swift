//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
import WebKit

class WebViewController: UIViewController {

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: self.view.frame, configuration: self.webViewConfiguration)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        return webView
    }()

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = WKUserContentController()
        return webViewConfiguration
    }()

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

    var userScripts: [WKUserScript] = [] {
        didSet {
            self.webViewConfiguration.userContentController.removeAllUserScripts()
            for userScript in self.userScripts {
                self.webViewConfiguration.userContentController.addUserScript(userScript)
            }
        }
    }

    private var shouldShowToolbar: Bool {
        return self.courseArea == .discussions || self.courseArea == .collabSpace
    }

    private var webViewCanGoBack: Bool {
        // WKWebView.canGoBack returns incorrect values as we have to set the headers for the request again.
        // So we check for the initial URL instead.
        return self.webView.url != self.url
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

        self.addWebView()
        self.webView.isHidden = true

        self.progress.alpha = 0.0

        if let cookie = TrackingHelper.trackingContextCookie(with: self) {
            self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }

        self.loadURL()

        self.toolbarItems = [self.backBarButton]

        UIView.animate(withDuration: defaultAnimationDuration, delay: 0.5, options: .curveLinear) {
            self.progress.alpha = CGFloat(1.0)
        }
    }

    func addWebView() {
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.largeTitleDisplayMode = .never

        if #available(iOS 15, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            self.navigationController?.toolbar.standardAppearance = appearance
            self.navigationController?.toolbar.scrollEdgeAppearance = appearance

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            self.navigationItem.standardAppearance = navigationBarAppearance
            self.navigationItem.scrollEdgeAppearance = navigationBarAppearance
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
            if let cookie = TrackingHelper.trackingContextCookie(with: self) {
                self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
    }

    override func removeFromParent() {
        super.removeFromParent()

        self.webView.navigationDelegate = nil
        if self.webView.isLoading {
            self.webView.stopLoading()
        }
    }

    private func loadURL() {
        guard let existingURL = self.url else { return }

        let request = NetworkHelper.request(for: existingURL) as URLRequest
        let completion: () -> Void = { self.webView.load(request) }
        if existingURL == Routes.singleSignOn {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                dataStore.removeData(
                    ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                    for: records.filter { Brand.default.host.contains($0.displayName) },
                    completionHandler: completion
                )
            }
        } else {
            completion()
        }
    }

    private func updateToolbarButtons() {
        self.backBarButton.isEnabled = self.webViewCanGoBack
    }

    @objc private func goBack() {
        guard self.webViewCanGoBack else { return }
        self.webView.stopLoading()
        self.webView.goBack()
        self.updateToolbarButtons()
    }

}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.shouldShowToolbar {
            self.updateToolbarButtons()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.progress.isHidden = true
        self.webView.isHidden = false

        if self.shouldShowToolbar {
            self.updateToolbarButtons()

            let pageViewController = self.parent as? UIPageViewController
            let isCurrentlyShownInCourse = pageViewController?.viewControllers?.first == self
            if isCurrentlyShownInCourse, self.navigationController?.toolbar.isHidden ?? false {
                self.navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let documentURL = Routes.isAppAuthenticationURL(for: navigationAction.request) {
            let urlComponents = URLComponents(url: documentURL, resolvingAgainstBaseURL: false)
            guard let queryItems = urlComponents?.queryItems else { return decisionHandler(.cancel) }

            if let tokenItem = queryItems.first(where: { $0.name == "token" }) {
                guard let token = tokenItem.value else { return decisionHandler(.cancel) }

                UserProfileHelper.shared.didLogin(withToken: token)
                self.loginDelegate?.didSuccessfullyLogin()
                self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled)
                return decisionHandler(.cancel)
            }

            return decisionHandler(.allow)
        } else if let documentURL = Routes.isSingleSignOnCallbackURL(for: navigationAction.request) {
            let modifiedURL = Routes.addCallbackParameters(to: documentURL)
            guard modifiedURL != documentURL else { return decisionHandler(.allow) }

            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = navigationAction.request
                    newRequest.url = modifiedURL
                    self.webView.load(newRequest)
                }
            }

            return decisionHandler(.cancel)
        }

        if navigationAction.request.httpMethod == "POST" {
            return decisionHandler(.allow)
        }

        if navigationAction.navigationType == .backForward {
            return decisionHandler(.allow)
        }

        let userIsLoggedIn = UserProfileHelper.shared.isLoggedIn
        let headerIsPresent = navigationAction.request.allHTTPHeaderFields?.keys.contains(Routes.Header.authKey) ?? false

        if userIsLoggedIn, !headerIsPresent, let url = navigationAction.request.url, url.host == Routes.base.host {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    var newRequest = navigationAction.request
                    newRequest.allHTTPHeaderFields = NetworkHelper.requestHeaders(for: url)
                    self.webView.load(newRequest)
                }
            }

            return decisionHandler(.cancel)
        }

        return decisionHandler(.allow)
    }
}

extension WebViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidEndDecelerating(scrollView)
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
        } else if let slug = course.slug, area == .collabSpace {
            self.url = Routes.courses.appendingPathComponents([slug, "learning_rooms"])
        }
    }

}
