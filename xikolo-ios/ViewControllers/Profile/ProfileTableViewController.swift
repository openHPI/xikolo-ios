//
//  ProfileTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 05.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var user: UserProfile?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            if let url = URL(string: Brand.IMPRINT_URL) {
                UIApplication.shared.openURL(url)
            }
        case 1:
            if let url = URL(string: Brand.PRIVACY_URL) {
                UIApplication.shared.openURL(url)
            }
        default:
            break
        }
    }

}
