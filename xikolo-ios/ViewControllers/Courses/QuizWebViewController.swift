//
//  QuizWebViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 24.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuizWebViewController : UIViewController {

    @IBOutlet weak var quizWebView: UIWebView!

    var courseItem: CourseItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        quizWebView.delegate = self

        if let courseID = courseItem.section?.course?.id {
            let courseURL = Routes.COURSES_URL + courseID
            let quizpathURL = "/items/" + courseItem.id
            let url = courseURL + quizpathURL
            quizWebView.loadRequest(NetworkHelper.getRequestForURL(url))
        }
    }

}

extension QuizWebViewController : UIWebViewDelegate {

    func webViewDidStartLoad(webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        NetworkIndicator.end()
    }

}
