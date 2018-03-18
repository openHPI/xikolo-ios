//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import DZNEmptyDataSet
import SafariServices
import UIKit

class CertificatesTableViewController: UITableViewController {

    var course: Course!

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell", for: indexPath)
        switch indexPath.row {
        case 0:
            let certificate = course.enrollment?.certificates?.confirmationOfParticipation
            cell.textLabel?.text = NSLocalizedString("course.certificates.confirmationOfParticipation", comment: "name of certificate")
            cell.detailTextLabel?.text = certificateState(certificate)
            cell.enable(certificate != nil)
        case 1:
            let certificate = course.enrollment?.certificates?.recordOfAchievement
            cell.textLabel?.text = NSLocalizedString("course.certificates.recordOfAchievement", comment: "name of certificate")
            cell.detailTextLabel?.text = certificateState(certificate)
            cell.enable(certificate != nil)
        case 2:
            let certificate = course.enrollment?.certificates?.certificate
            cell.textLabel?.text = NSLocalizedString("course.certificates.qualifiedCertificate", comment: "name of certificate")
            cell.detailTextLabel?.text = certificateState(certificate)
            cell.enable(certificate != nil)
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let url = course.enrollment?.certificates?.confirmationOfParticipation else { return }
            showCertificate(url: url)
        case 1:
            guard let url = course.enrollment?.certificates?.recordOfAchievement else { return }
            showCertificate(url: url)
        case 2:
            guard let url = course.enrollment?.certificates?.certificate else { return }
            showCertificate(url: url)
        default:
            break
        }
    }

    func showCertificate(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.preferredControlTintColor = Brand.windowTintColor
    }

    func certificateState(_ certificateURL: URL?) -> String {
        if certificateURL != nil {
            return NSLocalizedString("course.certificates.achieved", comment: "the current state of a certificate")
        } else {
            return NSLocalizedString("course.certificates.not-achieved", comment: "the current state of a certificate")
        }
    }

}

extension CertificatesTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

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

}
