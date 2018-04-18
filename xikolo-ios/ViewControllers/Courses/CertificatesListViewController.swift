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
    var certificates: [(name: String, explanation: String?, url: URL?)] = [] // swiftlint:disable:this large_tuple

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.certificates = self.course.availableCertificates
        self.tableView.reloadData()
    }

    func stateOfCertificate(withURL certificateURL: URL?) -> String {
        if certificateURL != nil {
            return NSLocalizedString("course.certificates.achieved", comment: "the current state of a certificate")
        } else {
            return NSLocalizedString("course.certificates.not-achieved", comment: "the current state of a certificate")
        }
    }

}

extension CertificatesListViewController { // TableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.certificates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = self.certificates[indexPath.row].url else { return }

        let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
        let pdfViewController = storyboard.instantiateViewController(withIdentifier: "PDFWebViewController").require(toHaveType: PDFWebViewController.self)
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell", for: indexPath)
        let certificate = self.certificates[indexPath.section]
        cell.textLabel?.text = certificate.name
        cell.detailTextLabel?.text = self.stateOfCertificate(withURL: certificate.url)
        cell.enable(certificate.url != nil)
        cell.accessoryType = certificate.url != nil ? .disclosureIndicator : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.certificates[section].explanation
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
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadEmptyDataSet()
    }

}
