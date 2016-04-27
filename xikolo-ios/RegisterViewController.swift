//
//  RegisterViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.06.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField! { didSet { emailTextField.delegate = self } }
    @IBOutlet weak var passwordTextField: UITextField! { didSet { passwordTextField.delegate = self } }
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func dismissAction(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        UserProfileHelper.login(email, password: password, completionHandler: {(token: String?, error: NSError?) -> () in
            if token != nil {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.passwordTextField.shake()
                // TODO: maybe check whether email is valid
            }
        });
    }

    @IBAction func registerButton(sender: AnyObject) {
        let url = NSURL(string: Routes.REGISTER_URL)
        UIApplication.sharedApplication().openURL(url!)

    }
    
    var pageIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.placeholder = NSLocalizedString("email", comment: "Email")
        self.passwordTextField.placeholder = NSLocalizedString("password", comment: "Password")
        self.registerButton.setTitle(NSLocalizedString("register", comment: "Register"), forState: UIControlState.Normal)
        emailTextField.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
