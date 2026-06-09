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

class CoBrandsSelectionTableViewCell: TableViewCell {

    override class var reuseIdentifier: String {
        return "co-brand-selection-cell"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let font = UIFont.systemFont(ofSize: 13)
        let underlineAttributes =
            [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.font: font
            ] as [NSAttributedString.Key: Any]?

        let cobrandsString =
            NSLocalizedString(
                "CobrandsDetectedText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )

        textLabel?.attributedText = NSAttributedString(string: cobrandsString, attributes: underlineAttributes)
        textLabel?.textAlignment = .right
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        textLabel?.frame = CGRect(x: leftMargin, y: 4, width: width, height: 36)
    }
}
