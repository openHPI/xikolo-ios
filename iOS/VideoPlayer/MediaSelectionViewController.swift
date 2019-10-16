//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import UIKit

class MediaSelectionViewController: UITableViewController {

    private let mediaCharacteristics: [AVMediaCharacteristic] = [.audible, .legible]

    private weak var delegate: MediaSelectionDelegate?

    init(delegate: MediaSelectionDelegate) {
        self.delegate = delegate

        if #available(iOS 13, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }

        self.view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        self.tableView.separatorColor = UIColor(white: 0.2, alpha: 1.0)
        self.tableView.allowsMultipleSelection = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("media-option-selection.navigation-bar.title",
                                                      comment: "navigation bar title for the media option selection")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.tableView.register(MediaSelectionOptionCell.self, forCellReuseIdentifier: MediaSelectionOptionCell.identifier)

        self.setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectCurrentOptions(animated: animated)
    }

    @objc private func close() {
        self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled) {
            self.delegate?.didCloseMediaSelection()
        }
    }

    private func selectCurrentOptions(animated: Bool) {
        for section in 0..<self.numberOfSections(in: self.tableView) {
            guard let mediaSelectionGroup = self.mediaSelectionGroup(forSection: section) else {
                continue
            }

            if let selectedMediaOption = self.delegate?.currentMediaSelection?.selectedMediaOption(in: mediaSelectionGroup) {
                if let index = mediaSelectionGroup.options.firstIndex(of: selectedMediaOption) {
                    let row = self.allowsEmptySelection(inSection: section) ? index + 1 : index
                    let indexPath = IndexPath(row: row, section: section)
                    self.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
                }
            } else {
                if self.allowsEmptySelection(inSection: section) {
                    let indexPath = IndexPath(row: 0, section: section)
                    self.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
                }
            }
        }
    }

}

// UITableViewDataSource

extension MediaSelectionViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.mediaCharacteristics.filter { self.multipleOptionAvailable(forMediaCharacteristic: $0) }.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(forSection: section) else { return 1 }
        return self.allowsEmptySelection(inSection: section) ? mediaSelectionGroup.options.count + 1 : mediaSelectionGroup.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MediaSelectionOptionCell.identifier, for: indexPath)
        cell.textLabel?.text = self.titleForOption(at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.mediaCharacteristic(forSection: section) {
        case .audible:
            return NSLocalizedString("media-option-selection.section.title.audio",
                                     comment: "section title for audio in the media option selection")
        case .legible:
            return NSLocalizedString("media-option-selection.section.title.subtitles",
                                     comment: "section title for subtitles and closed captions in the media option selection")
        default:
            return nil
        }
    }

    private func mediaCharacteristic(forSection section: Int) -> AVMediaCharacteristic {
        return self.mediaCharacteristics.filter { self.multipleOptionAvailable(forMediaCharacteristic: $0) }[section]
    }

    private func mediaSelectionGroup(forSection section: Int) -> AVMediaSelectionGroup? {
        let mediaCharacteristic = self.mediaCharacteristic(forSection: section)
        return self.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic)
    }

    private func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        return self.delegate?.currentMediaSelection?.asset?.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic)
    }

    private func multipleOptionAvailable(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> Bool {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) else { return false }
        return self.allowsEmptySelection(forMediaCharacteristic: mediaCharacteristic) || mediaSelectionGroup.options.count > 1
    }

    private func allowsEmptySelection(inSection section: Int) -> Bool {
        let mediaCharacteristic = self.mediaCharacteristic(forSection: section)
        return self.allowsEmptySelection(forMediaCharacteristic: mediaCharacteristic)
    }

    private func allowsEmptySelection(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> Bool {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) else { return false }
        return mediaSelectionGroup.allowsEmptySelection && mediaCharacteristic == .legible
    }

    private func titleForOption(at indexPath: IndexPath) -> String {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(forSection: indexPath.section) else {
            return NSLocalizedString("media-option-selection.cell.title.unknown",
                                     comment: "cell title for an unknonw option in the media option selection")
        }

        let allowsEmptySelection = self.allowsEmptySelection(inSection: indexPath.section)
        if allowsEmptySelection, indexPath.row == 0 {
            return NSLocalizedString("media-option-selection.cell.title.off",
                                     comment: "cell title for the off option in the media option selection")
        }

        let row = allowsEmptySelection ? indexPath.row - 1 : indexPath.row
        let mediaSelectionOption = mediaSelectionGroup.options[row]
        return mediaSelectionOption.displayName(with: Locale.current)
    }

}

// UITableViewDelegate

extension MediaSelectionViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(forSection: indexPath.section) else { return }

        let currentlySelectedIndexPath = self.tableView.indexPathsForSelectedRows?.first { $0.section == indexPath.section }
        if indexPath == currentlySelectedIndexPath { return }

        if let indexPathToDeselect = currentlySelectedIndexPath {
            self.tableView.deselectRow(at: indexPathToDeselect, animated: trueUnlessReduceMotionEnabled)
        }

        let allowsEmptySelection = self.allowsEmptySelection(inSection: indexPath.section)
        if allowsEmptySelection, indexPath.row == 0 {
            self.delegate?.select(nil, in: mediaSelectionGroup)
            self.tableView.selectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled, scrollPosition: .none)
        } else {
            let row = allowsEmptySelection ? indexPath.row - 1 : indexPath.row
            self.delegate?.select(mediaSelectionGroup.options[row], in: mediaSelectionGroup)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }

}

extension MediaSelectionViewController: EmptyStateDataSource {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.media-option-selection.title", comment: "title for empty media selection list")
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
    }

}
