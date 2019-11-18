//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class ChannelListViewController: UICollectionViewController {

    private var dataSource: CoreDataCollectionViewDataSource<ChannelListViewController>!

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.channelCell)

//        if let channelListLayout = self.collectionView?.collectionViewLayout as? CardListLayout {
//            channelListLayout.delegate = self
//        }

        super.viewDidLoad()

        self.addRefreshControl()

        let reuseIdentifier = R.reuseIdentifier.channelCell.identifier
        let request = ChannelHelper.FetchRequest.orderedChannels
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: [resultsController],
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           delegate: self)

        self.refresh()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = self.dataSource.object(at: indexPath)
        self.performSegue(withIdentifier: R.segue.channelListViewController.showCourseList, sender: channel)
//        self.appNavigator?.show(course: course)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11.0, *) {} else {
            self.collectionViewLayout.invalidateLayout()
        }
    }

    // TODO: needed?
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.channelListViewController.showCourseList(segue: segue), let channel = sender as? Channel {
            typedInfo.destination.configuration = .coursesInChannel(channel)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

//extension ChannelListViewController: CardListLayoutDelegate {
//
//    var cardInset: CGFloat {
//        return ChannelCell.cardInset
//    }
//
//    func minimalCardWidth(for traitCollection: UITraitCollection) -> CGFloat {
//        return ChannelCell.minimalWidth(for: traitCollection)
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        heightForCellAtIndexPath indexPath: IndexPath,
//                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
//
//        let channel = self.dataSource.object(at: indexPath)
//        return ceil(ChannelCell.heightForChannelList(forWidth: boundingWidth, for: channel))
//    }
//
//}

extension ChannelListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)

        let boundingWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        let channel = self.dataSource.object(at: indexPath)
        let height = ceil(ChannelCell.heightForChannelList(forWidth: boundingWidth, for: channel))

        return CGSize(width: boundingWidth, height: height)

        return CGSize(width: 400, height: 400)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - CourseCell.cardInset
        var rightPadding = collectionView.layoutMargins.right - CourseCell.cardInset

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
    }

}

extension ChannelListViewController: CoreDataCollectionViewDataSourceDelegate {

    typealias HeaderView = UICollectionReusableView

    func configure(_ cell: ChannelCell, for object: Channel) {
        cell.configure(object)
    }

}

extension ChannelListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return ChannelHelper.syncAllChannels().asVoid()
    }

}

