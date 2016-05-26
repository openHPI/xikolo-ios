//
//  QuizWebViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 24.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuizWebViewController: UIViewController, UIWebViewDelegate {
    
    var url: String? = nil

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    @IBOutlet weak var webViewNews: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webViewNews.delegate = self
        
        // Position of indicator
        activityIndicator.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3)
        activityIndicator.tag = 100
        
        if self.url != nil {
            let url = NSURL(string: self.url!)
            let request = NSMutableURLRequest(URL: url!)
            request.addValue(Routes.HEADER_USER_PLATFORM_VALUE, forHTTPHeaderField: Routes.HEADER_USER_PLATFORM)
            self.webViewNews.loadRequest(request)
        }
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
