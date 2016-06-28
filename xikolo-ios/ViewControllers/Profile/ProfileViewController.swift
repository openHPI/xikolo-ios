//
//  ProfileViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class ProfileViewController: AbstractTabContentViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var logoutButton: UIButton!

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func logout(sender: UIButton) {
        UserProfileHelper.logout()
        setViewData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.updateUIAfterLoginLogoutAction), name: NotificationKeys.loginSuccessfulKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.updateUIAfterLoginLogoutAction), name: NotificationKeys.logoutSuccessfulKey, object: nil)
        setupViews();
        setViewData();
    }
    
    override func viewWillAppear(animated: Bool) {
        updateUIAfterLoginLogoutAction()
    }
    
    func setupViews() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        self.profileImage.layer.borderWidth = 3.0;
        self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    func setViewData() {
        
        UserProfileHelper.self.getUser() { (user: UserProfile?, error: NSError?) -> () in
            if let user = user {
                // TODO: get name, username etc.

                ImageHelper.loadImageFromURL(user.visual, toImageView: self.profileImage)
            }
        };
    }

    override func updateUIAfterLoginLogoutAction() {
        super.updateUIAfterLoginLogoutAction()
        if !UserProfileHelper.isLoggedIn() {
            container.hidden = true
            profileImage.image = UIImage.init(imageLiteral: "avatar")
            logoutButton.hidden = true
        } else {
            container.hidden = false
            logoutButton.hidden = false
        }
    }

}
