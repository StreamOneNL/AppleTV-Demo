//
//  ItemCell.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 10-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    var representedItem: Item?
    var normalLabelConstraint: NSLayoutConstraint!
    var focussedLabelConstraint: NSLayoutConstraint!

    // MARK: Initialization

    override func awakeFromNib() {
        super.awakeFromNib()

        dateLabel.alpha = 0.0
        durationLabel.alpha = 0.0

        self.focussedLabelConstraint = imageView.focusedFrameGuide.bottomAnchor.constraintEqualToAnchor(titleLabel.topAnchor, constant: -20)
        self.focussedLabelConstraint.active = false

        self.normalLabelConstraint = imageView.bottomAnchor.constraintEqualToAnchor(titleLabel.topAnchor, constant: -20)
        self.normalLabelConstraint.active = true
    }

    // MARK: UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the label's alpha value so it's initially hidden.
        dateLabel.alpha = 0.0
        durationLabel.alpha = 0.0

        self.focussedLabelConstraint.active = false
        self.normalLabelConstraint.active = true
    }

    // MARK: UIFocusEnvironment

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
            Update the label's alpha value using the `UIFocusAnimationCoordinator`.
            This will ensure all animations run alongside each other when the focus
            changes.
        */

        coordinator.addCoordinatedAnimations({ [unowned self] in
            if self.focused {
                self.dateLabel.alpha = 1.0
                self.durationLabel.alpha = 1.0
                self.titleLabel.textColor = UIColor.whiteColor()
                self.normalLabelConstraint.active = false
                self.focussedLabelConstraint.active = true
            } else {
                self.dateLabel.alpha = 0.0
                self.durationLabel.alpha = 0.0
                self.titleLabel.textColor = UIColor.blackColor()
                self.focussedLabelConstraint.active = false
                self.normalLabelConstraint.active = true
            }

            self.layoutIfNeeded()
        }, completion: nil)
    }
}
