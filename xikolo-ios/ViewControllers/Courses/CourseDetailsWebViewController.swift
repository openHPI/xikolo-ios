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
        UserProfileHelper.createEnrollement(course.id).onSuccess { (nil) in
            self.course.is_enrolled = true
            CourseHelper.refreshCourses()
            self.performSegueWithIdentifier("UnwindSegueToCourseList", sender: sender)
        }
    }

    func createEnrollment() {
        UserProfileHelper.createEnrollement(course.id).onSuccess { (nil) in
            self.course.is_enrolled = true
            CourseHelper.refreshCourses()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.name

        if let courseID = course.course_code {
            let url = Routes.COURSES_URL + courseID
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
