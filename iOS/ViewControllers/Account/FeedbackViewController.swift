//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit
import Common
import CoreData

class FeedbackViewController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var issueTitleTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var issueTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var issueText: UITextView!

    //self.navigationItem.rightBarButtonItem?.isEnabled

    private lazy var courseTitles: [String] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        return result?.compactMap { $0.title } ?? []
    }()

    @IBAction func indexSelected(_ sender: Any) {
        if (issueTypeSegmentedControl.selectedSegmentIndex == 1){
            coursePicker.isHidden = false
        }
        else {
            coursePicker.isHidden = true
        }
    }

    @IBAction func issueTitleReturn(_ sender: UITextField) {
        let issueTitle = issueTitleTextField.text
        print ("issueTitle =", issueTitle)
    }

    @IBAction func mailAddressReturn(_ sender: UITextField) {
        let mailAddress = mailAddressTextField.text
        print ("mailAddress =", mailAddress!)
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction func send(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }
    
    func pickerView(_ pickerView: UIPickerView,
    didSelectRow row: Int,
    inComponent component: Int){
        let issueCourse = row
        print ("issueCourse =", issueCourse)
    }

    func pickerView(_ coursePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courseTitles.count
    }

    func numberOfComponents(in coursePicker: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ coursePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.courseTitles[row]
    }

    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coursePicker.isHidden = true

        if (Brand.default.features.enableReactivation) {
            issueTypeSegmentedControl.insertSegment(withTitle: "reactivation", at: 2, animated: false)
        }

        if let course = course {
            issueTypeSegmentedControl.removeAllSegments()
            issueTypeSegmentedControl.insertSegment(withTitle: course.title, at: 0, animated: false)
        }
}
}
