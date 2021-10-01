//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import SafariServices
import UIKit

class CertificatesListViewController: UICollectionViewController {

    var course: Course!
    var certificates: [Course.Certificate] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    weak var scrollDelegate: CourseAreaScrollDelegate?

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.certificateCell)

        super.viewDidLoad()

        self.certificates = self.course.availableCertificates
        self.addRefreshControl()
        self.refresh()
        self.setupEmptyState()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionView.performBatchUpdates(nil)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidEndDecelerating(scrollView)
    }

    func stateOfCertificate(withURL certificateURL: URL?) -> String {
        guard self.course.enrollment != nil else {
            return NSLocalizedString("course.certificates.not-enrolled", comment: "the current state of a certificate")
        }

        guard certificateURL != nil else {
            return NSLocalizedString("course.certificates.not-achieved", comment: "the current state of a certificate")
        }

        return NSLocalizedString("course.certificates.achieved", comment: "the current state of a certificate")
    }

}

extension CertificatesListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)

        let boundingWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        let minimalCardWidth = CertificateCell.minimalWidth(for: self.traitCollection)
        let numberOfColumns = floor(boundingWidth / minimalCardWidth)
        let columnWidth = boundingWidth / numberOfColumns

        let certificate = self.certificates[indexPath.item]
        let height = CertificateCell.height(for: certificate, forWidth: columnWidth, delegate: self)

        return CGSize(width: columnWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - CertificateCell.cardInset
        var rightPadding = collectionView.layoutMargins.right - CertificateCell.cardInset

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
    }

}

extension CertificatesListViewController { // CollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.certificates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = R.reuseIdentifier.certificateCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let certificate = self.certificates[indexPath.item]
        let stateOfCertificate = self.stateOfCertificate(withURL: certificate.url)

        if let cell = cell as? CertificateCell {
            cell.configure(certificate.name, explanation: certificate.explanation, url: certificate.url, stateOfCertificate: stateOfCertificate)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let certificate = self.certificates[indexPath.item]
        guard let url = certificate.url else { return }

        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        let filename = [self.course.title, certificate.name].compactMap { $0 }.joined(separator: " - ")
        pdfViewController.configure(for: url, filename: filename)
        self.show(pdfViewController, sender: self)
    }

}

extension CertificatesListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncCourse(self.course).onSuccess { _ in
            self.certificates = self.course.availableCertificates
        }.asVoid()
    }

}

extension CertificatesListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.certificates.no-certificates.title", comment: "title for empty certificates list")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.collectionView?.emptyStateDataSource = self
        self.collectionView?.emptyStateDelegate = self
    }

}

extension CertificatesListViewController: CertificateCellDelegate {

    func maximalHeightForTitle(withWidth width: CGFloat) -> CGFloat {
        return self.certificates.map { certificate -> CGFloat in
            return CertificateCell.heightForTitle(certificate.name, withWidth: width)
        }.max() ?? 0
    }

    func maximalHeightForStatus(withWidth width: CGFloat) -> CGFloat {
        return self.certificates.map { certificate -> CGFloat in
            let statusText = self.stateOfCertificate(withURL: certificate.url)
            return CertificateCell.heightForStatus(statusText, withWidth: width)
        }.max() ?? 0
    }

}

extension CertificatesListViewController: CourseAreaViewController {

    var area: CourseArea {
        return .certificates
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
        self.scrollDelegate = delegate
    }

}
