//
//  BingeMediaSelectionViewController.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import AVFoundation
import UIKit

class BingeMediaSelectionViewController: UITableViewController {

    private let delegate: BingeMediaSelectionDelegate & BingePlaybackRateDelegate
    private var mediaSelection: AVMediaSelection? {
        didSet {
            self.tableView.reloadData()
        }
    }

    init(delegate: BingeMediaSelectionDelegate & BingePlaybackRateDelegate) {
        self.mediaSelection = delegate.currentMediaSelection
        self.delegate = delegate
        super.init(style: .grouped)
        self.view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        self.tableView.separatorColor = UIColor(white: 0.2, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = BingeLocalizedString("media-option-selection.navigation-bar.title",
                                                         comment: "navigation bar title for the media option selection")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.tableView.register(BingePlaybackRateCell.self, forCellReuseIdentifier: BingePlaybackRateCell.identifier)
        self.tableView.register(BingeMediaOptionCell.self, forCellReuseIdentifier: BingeMediaOptionCell.identifier)
    }

    @objc private func close() {
        self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled) {
            self.delegate.didCloseMediaSelection()
        }
    }

}

// UITableViewDataSource

extension BingeMediaSelectionViewController  {


    override func numberOfSections(in tableView: UITableView) -> Int {
        let audioOptionAvailable = !(self.mediaSelectionGroup(for: 1)?.options.isEmpty ?? true)
        let subtitleOptionAvailable = !(self.mediaSelectionGroup(for: 2)?.options.isEmpty ?? true)

        var numberOfSections = 1
        if audioOptionAvailable { numberOfSections += 1 }
        if subtitleOptionAvailable { numberOfSections += 1 }
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(for: section) else { return 1 }
        return mediaSelectionGroup.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? BingePlaybackRateCell.identifier : BingeMediaOptionCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let playbackRateCell = cell as? BingePlaybackRateCell {
            playbackRateCell.delegate = self.delegate
        } else {
            cell.textLabel?.text = self.titleForOption(at: indexPath)
            cell.isSelected = self.optionIsSelected(at: indexPath)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return BingeLocalizedString("media-option-selection.section.title.playback-rate",
                                        comment: "section title for playback rate in the media option selection")
        case 1:
            return BingeLocalizedString("media-option-selection.section.title.audio",
                                        comment: "section title for audio in the media option selection")
        case 2:
            return BingeLocalizedString("media-option-selection.section.title.subtitles",
                                        comment: "section title for subtitles and closed captions in the media option selection")
        default:
            return nil
        }
    }

    private func mediaSelectionGroup(for section: Int) -> AVMediaSelectionGroup? {
        switch section {
        case 1:
            return self.mediaSelection?.asset?.mediaSelectionGroup(forMediaCharacteristic: .audible)
        case 2:
            return self.mediaSelection?.asset?.mediaSelectionGroup(forMediaCharacteristic: .legible)
        default:
            return nil
        }
    }

    private func allowsEmptySelection(in section: Int) -> Bool {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(for: section) else { return false }
        return mediaSelectionGroup.allowsEmptySelection && section == 2
    }

    private func titleForOption(at indexPath: IndexPath) -> String {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(for: indexPath.section) else {
            return BingeLocalizedString("media-option-selection.cell.title.unknown", comment: "cell title for an unknonw option in the media option selection")
        }

        let allowsEmptySelection = self.allowsEmptySelection(in: indexPath.section)
        if allowsEmptySelection, indexPath.row == 0 {
            return BingeLocalizedString("media-option-selection.cell.title.off", comment: "cell title for the off option in the media option selection")
        }

        let row = allowsEmptySelection ? indexPath.row - 1 : indexPath.row
        let mediaSelectionOption = mediaSelectionGroup.options[row]
        return mediaSelectionOption.displayName(with: Locale.current)
    }

    private func optionIsSelected(at indexPath: IndexPath) -> Bool {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(for: indexPath.section) else {
            return false
        }

        guard let selectedMediaOption = self.mediaSelection?.selectedMediaOption(in: mediaSelectionGroup) else {
            return indexPath.row == 0
        }

        let allowsEmptySelection = self.allowsEmptySelection(in: indexPath.section)
        if allowsEmptySelection, indexPath.row == 0 {
            return false
        }

        let row = allowsEmptySelection ? indexPath.row - 1 : indexPath.row
        let mediaSelectionOption = mediaSelectionGroup.options[row]
        return mediaSelectionOption == selectedMediaOption
    }

}

// UITableViewDelegate

extension BingeMediaSelectionViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mediaSelectionGroup = self.mediaSelectionGroup(for: indexPath.section) else { return }

        let allowsEmptySelection = self.allowsEmptySelection(in: indexPath.section)
        if allowsEmptySelection, indexPath.row == 0 {
            self.delegate.select(nil, in: mediaSelectionGroup)
        } else {
            let row = allowsEmptySelection ? indexPath.row - 1 : indexPath.row
            self.delegate.select(mediaSelectionGroup.options[row], in: mediaSelectionGroup)
        }

        self.mediaSelection = self.delegate.currentMediaSelection
    }
}
