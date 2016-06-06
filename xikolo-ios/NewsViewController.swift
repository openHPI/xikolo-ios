//
//  NewsViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 03.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UIWebViewDelegate{
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var webViewNews: UIWebView!
    @IBOutlet weak var webViewCourseActivity: UIWebView!
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            webViewCourseActivity.hidden = true
            webViewNews.hidden = false
        case 1:
            webViewCourseActivity.hidden = true
            webViewNews.hidden = false
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Position of indicator
        activityIndicator.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3)
        activityIndicator.tag = 100
        
        self.webViewNews.delegate = self
        let url = Routes.BASE_URL + Routes.NEWS
        self.webViewNews.loadRequest(NetworkHelper.getRequestForURL(url))
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.title = NSLocalizedString("tab_news", comment: "News")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
}