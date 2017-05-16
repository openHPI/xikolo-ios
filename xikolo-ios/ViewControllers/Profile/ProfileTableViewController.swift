//
//  ProfileTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 05.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import SafariServices

class ProfileTableViewController: UITableViewController {

    var user: UserProfile?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            if let url = URL(string: Brand.APP_IMPRINT_URL) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                safariVC.preferredControlTintColor = Brand.TintColor
            }
        case 1:
            if let url = URL(string: Brand.APP_PRIVACY_URL) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                safariVC.preferredControlTintColor = Brand.TintColor
            }
        default:
            break
        }
    }

}
