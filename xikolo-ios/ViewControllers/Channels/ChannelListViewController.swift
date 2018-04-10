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
        if let channelListLayout = self.collectionView?.collectionViewLayout as? ChannelListLayout {
            channelListLayout.delegate = self
        }

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

extension ChannelListViewController: ChannelListLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        if self.resultsControllerDelegateImplementation.isSearching && !self.resultsControllerDelegateImplementation.hasSearchResults {
            return 0.0
        }

        let channel = self.resultsControllerDelegateImplementation.visibleObject(at: indexPath)
        let imageHeight = boundingWidth / 2

        let boundingSize = CGSize(width: boundingWidth, height: CGFloat.infinity)
        let titleText = channel.name ?? ""
        let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                 options: .usesLineFragmentOrigin,
                                                                 attributes: titleAttributes,
                                                                 context: nil)

        let descriptionText = channel.channelDescription ?? ""
        let descriptionAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let descriptionSize = NSString(string: descriptionText).boundingRect(with: boundingSize,
                                                                       options: .usesLineFragmentOrigin,
                                                                       attributes: descriptionAttributes,
                                                                       context: nil)
        let maxDescriptionSize = NSString(string: "I\nI\nI").boundingRect(with: boundingSize,
                                                                          options: .usesLineFragmentOrigin,
                                                                          attributes: descriptionAttributes,
                                                                          context: nil)

        var height = imageHeight
        if !titleText.isEmpty {
            height += 6 + titleSize.height
        }

        if !titleText.isEmpty && !descriptionText.isEmpty {
            height += 4
        }

        if !descriptionText.isEmpty {
            height += min(descriptionSize.height, maxDescriptionSize.height)
        }

        return height
    }

    func topInset() -> CGFloat {
        return 0
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
