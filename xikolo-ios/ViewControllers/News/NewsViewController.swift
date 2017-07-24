//
//  NewsViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 03.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class NewsViewController : UIViewController {

    @IBOutlet weak var containerView: UIView!

    enum TabContent : Int {
        case announcements = 0
        case platformEvents = 1
    }

    var containerContentViewController: UIViewController?

    @IBAction func switchViewControllers(_ sender: UISegmentedControl) {
        if let position = TabContent(rawValue: sender.selectedSegmentIndex) {
            updateContainerView(position)
        }
    }

    override func viewDidLoad() {
        updateContainerView(.announcements)
        syncContent()
    }

    func syncContent() {
        AnnouncementHelper.syncAnnouncements()
        PlatformEventHelper.syncPlatformEvents()
    }

    func updateContainerView(_ position: TabContent) {
        // TODO: Animation?
        if let vc = containerContentViewController {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            containerContentViewController = nil
        }

        let storyboard = UIStoryboard(name: "TabNews", bundle: nil)
        switch position {
        case .announcements:
            let vc = storyboard.instantiateViewController(withIdentifier: "AnnouncementsTableViewController") as! AnnouncementsTableViewController
            changeToViewController(vc)
        case .platformEvents:
            let vc = storyboard.instantiateViewController(withIdentifier: "PlatformEventsTableViewController") as! PlatformEventsTableViewController
            changeToViewController(vc)
        }
        navigationController?.view.setNeedsLayout() // This is needed, because otherwise the navigation controller
        // won't notice that children swapped. But it is responsible for adjusting the content insets of the scroll
        // view. Without this, the bars would cover parts of the content.
    }

    func changeToViewController(_ viewController: UIViewController) {
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        containerContentViewController = viewController
    }

}
