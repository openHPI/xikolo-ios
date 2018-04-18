//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

//import Alamofire
import DZNEmptyDataSet
import SafariServices
import UIKit

class CertificatesListViewController: UITableViewController {

    var course: Course!

    var certificates: [(name: String, explanation: String, url: URL?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedSectionFooterHeight = 40
        tableView.estimatedRowHeight = 40
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        self.setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        certificates = course.availableCertificates
        super.viewWillAppear(animated)
        tableView.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func certificateState(_ certificateURL: URL?) -> String {
        if certificateURL != nil {
            return NSLocalizedString("course.certificates.achieved", comment: "the current state of a certificate")
        } else {
            return NSLocalizedString("course.certificates.not-achieved", comment: "the current state of a certificate")
        }
    }

}

extension CertificatesListViewController { // TableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return certificates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = certificates[indexPath.row].url else { return }

        let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
        let pdfViewController = storyboard.instantiateViewController(withIdentifier: "PDFWebViewController").require(toHaveType: PDFWebViewController.self)
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell", for: indexPath)
        cell.textLabel?.text = certificates[indexPath.row].name
        cell.detailTextLabel?.text = certificateState(certificates[indexPath.row].url)
        cell.enable(certificates[indexPath.row].url != nil)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UITableViewHeaderFooterView.init(reuseIdentifier: "explanationFooter")
        footerCell.textLabel?.text = certificates[section].explanation
        return footerCell
    }

}

extension CertificatesListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.certificates.no-certificates.title",
                                      comment: "title for empty certificates list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.certificates.no-certificates.description",
                                            comment: "description for empty certificates list")
        return NSAttributedString(string: description)
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

}
