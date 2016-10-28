//
//  CourseDetailsWebviewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseDetailsWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var course: Course!

    @IBAction func enrollButton(sender: UIBarButtonItem) {
        if UserProfileHelper.isLoggedIn() {
            createEnrollment()
        } else {
            performSegueWithIdentifier("ShowLoginFromDetailsView", sender: sender)
        }
    }

    func createEnrollment() {
        UserProfileHelper.createEnrollement(course.id).onSuccess {
            CourseHelper.refreshCourses()
            self.performSegueWithIdentifier("UnwindSegueToCourseList", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.title

        let url = Routes.COURSES_URL + course.id
        webView.loadRequest(NetworkHelper.getRequestForURL(url))
    }

}

extension CourseDetailsWebViewController : UIWebViewDelegate {

    func webViewDidStartLoad(webView: UIWebView) {
        NetworkIndicator.start()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        NetworkIndicator.end()
    }
}
