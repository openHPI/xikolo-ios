//
//  DashboardViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var deadlinesWebView: UIWebView!
    @IBOutlet weak var notificationsWebView: UIWebView!
    @IBOutlet weak var deadlinesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notificationsActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDeadlinesWebView()
        loadNotificationsWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDeadlinesWebView() {
        self.deadlinesWebView.delegate = self
        let url = Routes.BASE_URL + Routes.NEWS  // TODO: change url to deadlines
        self.deadlinesWebView.loadRequest(NetworkHelper.getRequestForURL(url))
    }
    
    func loadNotificationsWebView() {
        self.notificationsWebView.delegate = self
        let url = Routes.BASE_URL + Routes.NEWS  // TODO: change url to notifications
        self.notificationsWebView.loadRequest(NetworkHelper.getRequestForURL(url))
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        switch webView.tag {
        case 10:
            deadlinesActivityIndicator.hidden = false
            deadlinesActivityIndicator.startAnimating()
        case 20:
            notificationsActivityIndicator.hidden = false
            notificationsActivityIndicator.startAnimating()
        default:
            break
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        switch webView.tag {
        case 10:
            deadlinesActivityIndicator.hidden = true
            deadlinesActivityIndicator.stopAnimating()
        case 20:
            notificationsActivityIndicator.hidden = true
            notificationsActivityIndicator.stopAnimating()
        default:
            break
        }
    }
    
}
