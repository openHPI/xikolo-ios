//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import DZNEmptyDataSet
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
        if let certificateListLayout = self.collectionView?.collectionViewLayout as? CardListLayout {
            certificateListLayout.delegate = self
        }

        super.viewDidLoad()

        self.certificates = self.course.availableCertificates
        self.addRefreshControl()
        self.refresh()
        self.setupEmptyState()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
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

extension CertificatesListViewController: CardListLayoutDelegate {

    var followReadableWidth: Bool {
        return true
    }

    var cardInset: CGFloat {
        return CertificateCell.cardInset
    }

    func minimalCardWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return CertificateCell.minimalWidth(for: traitCollection)
    }

    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        let certificate = self.certificates[indexPath.item]
        let height = CertificateCell.height(for: certificate, forWidth: boundingWidth, delegate: self)
        return ceil(height)
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
        self.navigationController?.pushViewController(pdfViewController, animated: trueUnlessReduceMotionEnabled)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionView.performBatchUpdates(nil)
    }

}

extension CertificatesListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncCourse(self.course).onSuccess { _ in
            self.certificates = self.course.availableCertificates
        }.asVoid()
    }

}

extension CertificatesListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.certificates.no-certificates.title", comment: "title for empty certificates list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "")
    }

    func setupEmptyState() {
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        self.collectionView?.reloadEmptyDataSet()
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
