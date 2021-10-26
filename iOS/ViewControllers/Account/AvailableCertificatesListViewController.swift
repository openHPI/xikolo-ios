//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class AvailableCertificatesListViewController: UITableViewController {

    typealias CertificateData = (courseTitle: String?, certificates: [Enrollment.Certificate])

    var certificates: [CertificateData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var courseID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupEmptyState()
        self.refresh()

        EnrollmentHelper.syncEnrollments().onSuccess { [weak self] _ in
            self?.refresh()
        }
    }

    private func refresh() {
        self.reloadData().onSuccess { [weak self] certificates in
            self?.certificates = certificates
        }
    }

    private func reloadData() -> Future<[CertificateData], XikoloError> {
        let promise = Promise<[CertificateData], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            do {
                let request = EnrollmentHelper.FetchRequest.allEnrollments()
                let enrollments = try context.fetch(request)

                let certificateList = enrollments.compactMap { enrollment -> (String?, [Enrollment.Certificate])? in
                    let earnedCertificates = enrollment.earnedCertificates
                    guard !earnedCertificates.isEmpty else { return nil }
                    return (enrollment.course?.title, enrollment.earnedCertificates)
                }

                return promise.success(certificateList)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.certificates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.certificates[section].certificates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.certificateOverviewCell, for: indexPath).require()
        cell.textLabel?.text = self.certificates[indexPath.section].certificates[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.certificates[section].courseTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let certificate = certificates[indexPath.section].certificates[indexPath.row]
        self.performSegue(withIdentifier: R.segue.availableCertificatesListViewController.showCertificate.identifier, sender: certificate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.availableCertificatesListViewController.showCertificate(segue: segue) {
            if let certificate = sender as? Enrollment.Certificate {
                typedInfo.destination.configure(for: certificate.url, filename: certificate.name)
            }
        }
    }

}

extension AvailableCertificatesListViewController: EmptyStateDataSource {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.account.certificates.no-certificates.title", comment: "title for empty certificates list")
    }

    var emptyStateDetailText: String? {
        return NSLocalizedString("empty-view.account.certificates.no-certificates.description", comment: "description for empty certificates list")
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.tableFooterView = UIView()
    }

}
