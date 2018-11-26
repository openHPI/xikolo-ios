//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class AvailableCertificatesListViewController: UITableViewController {

    struct Certificate {
        var title: String?
        var courseTitle: String?
        var url: URL
    }

    var certificates: [[Certificate]] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var courseID: String!

    typealias Certificates = EnrollmentCertificates

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refresh()
        EnrollmentHelper.syncEnrollments().onSuccess { _ in
            self.refresh()
        }
    }

    func refresh() {
        self.reloadData().onSuccess { certificates in
            self.certificates = certificates
        }
    }

    func reloadData() -> Future<[[Certificate]], XikoloError> {
        let promise = Promise<[[Certificate]], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                var certificateList: [[Certificate]] = []
                let request = EnrollmentHelper.FetchRequest.allEnrollments()
                let enrollments = try privateManagedObjectContext.fetch(request)
                for enrollment in enrollments {
                    var courseCertificates: [Certificate] = []
                    if let enrollmentCertificates = enrollment.certificates {
                        if let url = enrollmentCertificates.confirmationOfParticipation {
                            let courseTitle = enrollment.course?.title
                            let title = NSLocalizedString("course.certificates.name.confirmationOfParticipation", comment: "name of the certificate")
                            courseCertificates.append(Certificate(title: title, courseTitle: courseTitle, url: url))
                        }

                        if let url = enrollmentCertificates.recordOfAchievement {
                            let courseTitle = enrollment.course?.title
                            let title = NSLocalizedString("course.certificates.name.recordOfAchievement", comment: "name of the certificate")
                            courseCertificates.append(Certificate(title: title, courseTitle: courseTitle, url: url))
                        }

                        if let url = enrollmentCertificates.qualifiedCertificate {
                            let courseTitle = enrollment.course?.title
                            let title = NSLocalizedString("course.certificates.name.qualifiedCertificate", comment: "name of the certificate")
                            courseCertificates.append(Certificate(title: title, courseTitle: courseTitle, url: url))
                        }

                    }

                    if !courseCertificates.isEmpty {
                        certificateList.append(courseCertificates)
                    }
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
        return self.certificates[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.certificateOverviewCell, for: indexPath).require()
        cell.textLabel?.text = self.certificates[indexPath.section][indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.certificates[section].first?.courseTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let certificate = certificates[indexPath.section][indexPath.row]
        performSegue(withIdentifier: R.segue.availableCertificatesListViewController.showCertificate.identifier, sender: certificate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.availableCertificatesListViewController.showCertificate(segue: segue) {
            if let certificate = sender as? Certificate {
                typedInfo.destination.configure(for: certificate.url, filename: certificate.title)
            }
        }
    }

}
