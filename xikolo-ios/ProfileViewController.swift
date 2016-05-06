//
//  ProfileViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var containerTableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews();
        setViewData();
    }
    
    override func viewWillAppear(animated: Bool) {
        relayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.title = NSLocalizedString("tab_profile", comment: "Profile")
    }
    @IBAction func logout(sender: UIButton) {
        UserProfileHelper.logout()
        relayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        self.profileImage.layer.borderWidth = 3.0;
        self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    func setViewData() {
        self.logoutButton.setTitle(NSLocalizedString("logout", comment: "Logout"), forState: UIControlState.Normal)
        
        UserProfileHelper.self.getUser() { (user: UserProfile?, error: NSError?) -> () in
            if let user = user {
                //self.nameLabel.text = user.firstName + " " + user.lastName
                //self.emailLabel.text = user.email

                ImageHelper.loadImageFromURL(user.visual, toImageView: self.profileImage)
            }
        };
    }
    
    func relayout() {
        if !UserProfileHelper.isLoggedIn() {
            logoutButton.hidden = true
            loginButton.hidden = false
            containerTableView.hidden = true
        } else {
            containerTableView.hidden = false
            logoutButton.hidden = false
            loginButton.hidden = true
        }
    }
}
