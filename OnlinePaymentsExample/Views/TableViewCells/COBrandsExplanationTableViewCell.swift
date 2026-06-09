/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import UIKit
import OnlinePaymentsKit

class COBrandsExplanationTableViewCell: TableViewCell {

    override class var reuseIdentifier: String {
        return "co-brand-explanation-cell"
    }
    var limitedBackgroundView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.attributedText = COBrandsExplanationTableViewCell.cellString()
        textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel?.numberOfLines = 0
        limitedBackgroundView.addSubview(textLabel!)
        limitedBackgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.contentView.addSubview(limitedBackgroundView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    class func cellString() -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 12)
        let fontAttribute = [NSAttributedString.Key.font: font]

        let cellString =
            NSLocalizedString(
                "CobrandsIntroText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        let cellStringWithFont = NSAttributedString(string: cellString, attributes: fontAttribute)

        return cellStringWithFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        limitedBackgroundView.frame = CGRect(x: leftMargin, y: 4, width: width, height: (self.textLabel?.frame.height)!)
        textLabel?.frame = limitedBackgroundView.bounds
    }
}
