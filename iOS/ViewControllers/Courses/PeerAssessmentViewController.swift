//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class PeerAssessmentViewController: UIViewController {

    @IBOutlet private weak var assessmentTitleLabel: UILabel!
    @IBOutlet private weak var assessmentTypeLabel: UILabel!
    @IBOutlet private weak var assessmentInstructionsView: UITextView!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var redirectButton: UIButton!

    weak var delegate: CourseItemViewController?

    private var courseItemObserver: ManagedObjectObserver?

    private var courseItem: CourseItem! {
        didSet {
            self.courseItemObserver = ManagedObjectObserver(object: self.courseItem) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.redirectButton.layer.roundCorners(for: .default)

        self.updateView()
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    func updateView() {
        guard let peerAssessment = self.courseItem?.content as? PeerAssessment else { return }

        self.assessmentTitleLabel.text = peerAssessment.id
        self.assessmentTypeLabel.text = peerAssessment.type
        self.assessmentInstructionsView.text = peerAssessment.instructions
        self.noteLabel.text = NSLocalizedString("course.item-not.optimized", comment: "course item not optimized for the app")
        self.redirectButton.backgroundColor = Brand.default.colors.primary

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = self.courseItem, let _
        = item.content as? PeerAssessment else { return }
        if let typedInfo = R.segue.iOSPeerAssessmentViewController.openPeerAssessmentURL(segue: segue) {
            typedInfo.destination.url = item.url
               }
    }
}

extension PeerAssessmentViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
