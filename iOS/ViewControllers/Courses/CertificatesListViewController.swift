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
    
    // private var dataSource: CoreDataCollectionViewDataSource<CertificatesListViewController>!

    var course: Course!
    var certificates: [(name: String, explanation: String?, url: URL?)] = [] { // swiftlint:disable:this large_tuple
        didSet {
            //self.tableView.reloadData()
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.certificateCell)
//        self.collectionView?.register(UINib(resource: R.nib.courseHeaderView),
//                                      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
//                                      withReuseIdentifier: R.nib.courseHeaderView.name)
        
        if let certificateListLayout = self.collectionView?.collectionViewLayout as? CertificateListLayout {
            certificateListLayout.delegate = self
        }
        
        collectionView?.delegate = self
        collectionView?.dataSource = self // ????
        
        super.viewDidLoad()
        
        self.certificates = self.course.availableCertificates
        self.addRefreshControl()
        self.refresh()
        self.setupEmptyState()
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

extension CertificatesListViewController: CertificateListLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
//        if self.dataSource.isSearching && !self.dataSource.hasSearchResults {
//            return 0.0
//        }
        
//        let course = self.dataSource.object(at: indexPath)
        let cardWidth = boundingWidth - 2 * 14
        let imageHeight = cardWidth / 2
        
        let boundingSize = CGSize(width: cardWidth, height: CGFloat.infinity)
        let titleText = self.course.title ?? ""
        let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                 options: .usesLineFragmentOrigin,
                                                                 attributes: titleAttributes,
                                                                 context: nil)
        
        let teachersText = self.course.teachers ?? ""
        let teachersAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let teachersSize = NSString(string: teachersText).boundingRect(with: boundingSize,
                                                                       options: .usesLineFragmentOrigin,
                                                                       attributes: teachersAttributes,
                                                                       context: nil)
        
        var height = imageHeight + 14
        
        if Brand.default.features.showCourseTeachers {
            if !titleText.isEmpty || !teachersText.isEmpty {
                height += 8
            }
            
            if !titleText.isEmpty {
                height += titleSize.height
            }
            
            if !titleText.isEmpty && !teachersText.isEmpty {
                height += 4
            }
            
            if !teachersText.isEmpty {
                height += teachersSize.height
            }
        } else {
            if !titleText.isEmpty {
                height += 8 + titleSize.height
            }
        }
        
        return height + 5
    }
    
    func topInset() -> CGFloat {
        return 0
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
            cell.configure(certificate, stateOfCertificate: stateOfCertificate)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = self.certificates[indexPath.section].url else { return }
        
        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionView?.performBatchUpdates(nil)
    }
    
}

//extension CertificatesListViewController { // TableViewDelegate

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return self.certificates.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let url = self.certificates[indexPath.section].url else { return }
//
//        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
//        pdfViewController.url = url
//        self.navigationController?.pushViewController(pdfViewController, animated: true)
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell", for: indexPath)
//        let certificate = self.certificates[indexPath.section]
//        cell.textLabel?.text = certificate.name
//        cell.textLabel?.backgroundColor = .white
//        cell.detailTextLabel?.text = self.stateOfCertificate(withURL: certificate.url)
//        cell.detailTextLabel?.backgroundColor = .white
//        cell.enable(certificate.url != nil)
//        cell.accessoryType = certificate.url != nil ? .disclosureIndicator : .none
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return self.certificates[section].explanation
//    }

//}


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

extension CertificatesListViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        self.course = course
    }

}
