//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import DZNEmptyDataSet
import SafariServices
import UIKit

class CertificatesListViewController: UITableViewController {

    var course: Course!

    var certificates: [(name: String, url: URL?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        certificates = findAvailableCertificates()
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func showCertificate(url: URL) {
        let config = URLSessionConfiguration.background(withIdentifier: "com.example.DownloadTaskExample.background")
        config.httpAdditionalHeaders  = NetworkHelper.getRequestHeaders()
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let task = session.downloadTask(with: url)
        task.resume()





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

    func findAvailableCertificates() -> [(String, URL?)] {
        var certificates: [(String, URL?)] = []
        if let cop = course.certificates?.confirmationOfParticipation, cop.available {
            let name = NSLocalizedString("course.certificates.confirmationOfParticipation", comment: "name of certificate")
            let url = course.enrollment?.certificates?.confirmationOfParticipation
            certificates.append((name, url))
        }

        if let roa = course.certificates?.recordOfAchievement, roa.available {
            let name = NSLocalizedString("course.certificates.recordOfAchievement", comment: "name of certificate")
            let url = course.enrollment?.certificates?.recordOfAchievement
            certificates.append((name, url))
        }

        if let cop = course.certificates?.qualifiedCertificate, cop.available {
            let name = NSLocalizedString("course.certificates.qualifiedCertificate", comment: "name of certificate")
            let url = course.enrollment?.certificates?.qualifiedCertificate
            certificates.append((name, url))
        }

        return certificates
    }

}

extension CertificatesListViewController { // TableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = certificates[indexPath.row].url {
            let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController").require(toHaveType: WebViewController.self)
            vc.url = url.absoluteString
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell", for: indexPath)
        cell.textLabel?.text = certificates[indexPath.row].name
        cell.detailTextLabel?.text = certificateState(certificates[indexPath.row].url)
        cell.enable(certificates[indexPath.row].url != nil)
        return cell
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

extension CertificatesListViewController : URLSessionTaskDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log.info("Certificate successfully downloaded to: " + location.absoluteString)
        //try? FileManager.default.removeItem(at: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        log.error(error.debugDescription)
    }


}
