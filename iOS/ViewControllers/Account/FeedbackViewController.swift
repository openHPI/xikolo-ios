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
    @IBAction func indexSelected(_ sender: Any) {
        if (issueTypeSegmentedControl.selectedSegmentIndex == 1){
            coursePicker.isHidden = false
        }
    }
    @IBAction func choseFeedback(_ sender: Any) {
        coursePicker.isHidden = false
    }
    @IBAction func issueTitleReturn(_ sender: UITextField) {
        let issueTitle = issueTitleTextField.text
        print ("issueTitle =", issueTitle ?? "")
    }
    @IBAction func mailAddressReturn(_ sender: UITextField) {
        let mailAddress = mailAddressTextField.text
        print ("mailAddress =", mailAddress ?? "")
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
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        let titles = result?.compactMap { $0.title } ?? []
        return titles.count
    }
    func numberOfComponents(in coursePicker: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ coursePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        let titles = result?.compactMap { $0.title } ?? []
        return titles[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        coursePicker.isHidden = true

//        if Brand.copyrightName = "sap" {
//            issueTypeSegmentedControl.insertSegment(withTitle: "reactivation", at: 2, animated: false)
//        }
}
}
