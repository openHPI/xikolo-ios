//
//  QuizWebViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 24.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuizWebViewController: UIViewController, UIWebViewDelegate {

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    @IBOutlet weak var webViewNews: UIWebView!
    
    var courseItem: CourseItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webViewNews.delegate = self
        
        // Position of indicator
        activityIndicator.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3)
        activityIndicator.tag = 100
        
        if let courseID = courseItem.section?.course?.id {
            let courseURL = Routes.BASE_URL + Routes.COURSES + courseID
            let quizpathURL = "/items/" + courseItem.id!
            let url = courseURL + quizpathURL
            self.webViewNews.loadRequest(NetworkHelper.getRequestForURL(url))
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
