//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import UIKit

private let reuseIdentifier = "ChannelCell"

class ChannelListViewController: UICollectionViewController {

    var resultsController: NSFetchedResultsController<Channel>!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Channel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsController = CoreDataHelper.createResultsController(ChannelHelper.FetchRequest.allChannels, sectionNameKeyPath: "name")
        

        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(self.collectionView,
                                                                                                        resultsControllers: [resultsController],
                                                                                                        cellReuseIdentifier: reuseIdentifier)
        //resultsControllerDelegateImplementation.headerReuseIdentifier = "CourseHeaderView"
        let configuration = ChannelListViewConfiguration().wrapped
        self.resultsControllerDelegateImplementation.configuration = configuration

        self.resultsController.delegate = resultsControllerDelegateImplementation
        self.collectionView?.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }

        ChannelHelper.syncAllChannels()
    }

}

struct ChannelListViewConfiguration: CollectionViewResultsControllerConfiguration {
    typealias Content = Channel

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<ChannelListViewConfiguration.Content>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: ChannelCell.self, hint: "ChannelList requires cells of type ChannelCell")
        let channel = controller.object(at: indexPath)
        cell.configure(channel)
    }

}
