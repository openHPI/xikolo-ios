//
//  ProfileTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 05.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 1 || indexPath.row == 2 || indexPath.row  == 3 {
            return true
        }
        return false
    }
    
}
