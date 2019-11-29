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

        super.viewDidLoad()

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }

        self.adjustScrollDirection(for: self.collectionView.bounds.size)

        let reuseIdentifier = R.reuseIdentifier.channelCell.identifier
        let request = ChannelHelper.FetchRequest.orderedChannels
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: [resultsController],
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           delegate: self)

        self.refresh()
        self.setupEmptyState()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = self.dataSource.object(at: indexPath)
        self.performSegue(withIdentifier: R.segue.channelListViewController.showCourseList, sender: channel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11.0, *) {} else {
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adjustScrollDirection(for: self.collectionView.bounds.size)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.adjustScrollDirection(for: size)

        // swiftlint:disable:next trailing_closure
        coordinator.animate(alongsideTransition: { _  in
            self.collectionViewLayout.invalidateLayout()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.channelListViewController.showCourseList(segue: segue), let channel = sender as? Channel {
            typedInfo.destination.configuration = .coursesInChannel(channel)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func adjustScrollDirection(for size: CGSize) {
        let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = self.traitCollection.horizontalSizeClass == .regular && size.width > size.height ? .horizontal : .vertical
    }

}

extension ChannelListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)

        var boundingWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right

        if self.traitCollection.horizontalSizeClass == .regular, collectionView.bounds.width > collectionView.bounds.height {
            boundingWidth = min(600, boundingWidth)
        }

        let channel = self.dataSource.object(at: indexPath)
        let height = ceil(ChannelCell.heightForChannelList(forWidth: boundingWidth, for: channel))

        return CGSize(width: boundingWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - ChannelCell.cardInset
        var rightPadding = collectionView.layoutMargins.right - ChannelCell.cardInset

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

extension ChannelListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.channels.title", comment: "title for empty channel list")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.collectionView.emptyStateDataSource = self
        self.collectionView.emptyStateDelegate = self
    }

}

extension ChannelListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return ChannelHelper.syncAllChannels().asVoid()
    }

}
