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
            createEnrollment(sender)
        } else {
            performSegueWithIdentifier("ShowLoginFromDetailsView", sender: sender)
        }
    }

    func createEnrollment(sender: UIBarButtonItem) {
        UserProfileHelper.createEnrollement(course.id) { success, error in
            if success {
                self.course.is_enrolled = true
                CourseHelper.refreshCourses()
                self.performSegueWithIdentifier("UnwindSegueToCourseList", sender: sender)
            } else {
                // TODO: Error handling.
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.name

        webView.delegate = self

        if let courseID = course.course_code {
            let url = Routes.BASE_URL + Routes.COURSES + courseID
            webView.loadRequest(NetworkHelper.getRequestForURL(url))
        }
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
