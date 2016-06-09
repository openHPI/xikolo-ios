//
//  EditProfileSettingsViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class EditProfileSettingsViewController: UIViewController, UITextFieldDelegate {
    
    var currentText = "currentSetting"
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        dismiss(true)
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismiss(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        textField.text = currentText
    }
    
    func dismiss(shouldSave: Bool) -> () {
        if shouldSave {
            // TODO: set new Value online
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
