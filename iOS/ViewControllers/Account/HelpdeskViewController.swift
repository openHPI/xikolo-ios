//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import SafariServices
import UIKit

class HelpdeskViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var hintWrapper: UIView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var topicLabel: UILabel!
    @IBOutlet private weak var reportTextView: UITextView!
    @IBOutlet private weak var issueTextCell: UITableViewCell!
    @IBOutlet private weak var onFailureLabel: UILabel!

    private lazy var sendBarButtonItem: UIBarButtonItem = {
        let title = NSLocalizedString("helpdesk.action.send", comment: "Label of button for submitting a helpdesk ticket")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(sendTicket))
    }()

    private lazy var waitIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Brand.default.colors.window
        return indicator
    }()

    private lazy var waitBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.waitIndicator)
    }()

    private var topic: HelpdeskTicket.Topic = .technical {
        didSet {
            self.topicLabel.text = self.topic.displayName
        }
    }

    var hasValidInput: Bool {
        guard let issueTitle = self.titleTextField.text, !issueTitle.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }
        guard let mailAddress = self.mailAddressTextField.text, !mailAddress.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }
        guard let issueReport = self.reportTextView.text, !issueReport.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }

        return true
    }

    var course: Course?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        self.topicLabel.text = self.topic.displayName

        self.tableView.delegate = self
        self.titleTextField.delegate = self
        self.mailAddressTextField.delegate = self
        self.reportTextView.delegate = self
        self.reportTextView.textContainerInset = UIEdgeInsets.zero
        self.reportTextView.textContainer.lineFragmentPadding = 0

        self.onFailureLabel.isHidden = true

        let hintTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFAQs))
        self.hintWrapper.addGestureRecognizer(hintTapGestureRecognizer)
        self.hintWrapper.layer.roundCorners(for: .default)

        // Set FAQ hint label text with highlighted 'FAQ'
        let hintText = NSLocalizedString("helpdesk.hint.faq", comment: "hint for checking the FAQ before creating a helpdesk ticket")
        let range = NSString(string: hintText).range(of: "FAQ")
        let attributedText = NSMutableAttributedString(string: hintText, attributes: [.font: UIFont.preferredFont(forTextStyle: .callout)])
        attributedText.addAttributes([.foregroundColor: Brand.default.colors.window], range: range)
        self.hintLabel.attributedText = attributedText

        self.tableView.resizeTableHeaderView()

        if let course = self.course {
            self.topic = .courseSpecific(course)
        }

        if UserProfileHelper.shared.isLoggedIn {
            CoreDataHelper.viewContext.perform {
                guard let userId = UserProfileHelper.shared.userId else { return }
                let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
                guard let user = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return }
                self.mailAddressTextField.text = user.profile?.email
                self.mailAddressTextField.isUserInteractionEnabled = false
                self.mailAddressTextField.textColor = .gray
            }
        }

        let backgroundTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        backgroundTapGestureRecognizer.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(backgroundTapGestureRecognizer)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.tableView.resizeTableHeaderView()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
        }

        if indexPath.section == 0 {
            self.titleTextField.becomeFirstResponder()
        } else if indexPath.section == 1 {
            self.mailAddressTextField.becomeFirstResponder()
        } else if indexPath.section == 3 {
            self.reportTextView.becomeFirstResponder()
        } else if indexPath.section == 2 {
            let topicSelectionViewController = HelpdeskTicketTopicListViewController(selectedTopic: self.topic) { topic in
                self.topic = topic
            }

            let navigationController = UINavigationController(rootViewController: topicSelectionViewController)
            self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
        }
    }

    @IBAction private func issueAttributeChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = self.hasValidInput

        if #available(iOS 13.0, *) {
            guard let issueTitle = self.titleTextField.text, !issueTitle.isEmpty else {
                isModalInPresentation = true
                return
            }

            if !UserProfileHelper.shared.isLoggedIn {
                guard let mailAddress = self.mailAddressTextField.text, !mailAddress.isEmpty else {
                isModalInPresentation = true
                return
                }

            }

            guard let issueReport = self.reportTextView.text, !issueReport.isEmpty else {
                isModalInPresentation = true
                return
            }

            isModalInPresentation = false

        }

    }

    @IBAction private func cancelTicketComposition() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func sendTicket() {
        guard let title = titleTextField.text else { return }
        guard let mail = mailAddressTextField.text else { return }
        guard let report = reportTextView.text else { return }

        let ticket = HelpdeskTicket(title: title, mail: mail, topic: self.topic, report: report)

        self.navigationItem.rightBarButtonItem = self.waitBarButtonItem
        self.waitIndicator.startAnimating()

        HelpdeskTicketHelper.createIssue(ticket).onSuccess { [weak self] _ in
            self?.dismiss(animated: trueUnlessReduceMotionEnabled)
        }.onFailure { [weak self] _ in
            self?.onFailureLabel.isHidden = false
            self?.tableView.resizeTableHeaderView()
            self?.tableView.setContentOffset(.zero, animated: trueUnlessReduceMotionEnabled)
        }.onComplete { [weak self] _ in
            self?.navigationItem.rightBarButtonItem = self?.sendBarButtonItem
        }
    }

    @IBAction private func dismissKeyboard() {
        self.titleTextField.resignFirstResponder()
        self.mailAddressTextField.resignFirstResponder()
        self.reportTextView.resignFirstResponder()
    }

    @objc private func showFAQs() {
        let safariVC = SFSafariViewController(url: Routes.faq)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
    }

}

extension HelpdeskViewController: UITextViewDelegate {

    func textViewDidChange(_ tableView: UITextView) {
        self.issueAttributeChanged()

        // use of performWithoutAnimation() in order to avoid rocking of the textView
        UIView.performWithoutAnimation {
            self.reportTextView.sizeToFit()
            self.issueTextCell.sizeToFit()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

extension HelpdeskViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == self.titleTextField && !UserProfileHelper.shared.isLoggedIn {
            self.mailAddressTextField.becomeFirstResponder()
        } else if textField === self.mailAddressTextField || textField == self.titleTextField && UserProfileHelper.shared.isLoggedIn {
            self.reportTextView.becomeFirstResponder()
            // jump to textView
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
        }

        return true
    }

}
