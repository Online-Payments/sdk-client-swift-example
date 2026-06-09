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

class ButtonTableViewCell: TableViewCell {
    private var button: Button = Button()

    override class var reuseIdentifier: String { return "button-cell" }

    var buttonType: ExampleButtonType {
        get {
            return button.exampleButtonType
        }
        set {
            button.exampleButtonType = newValue
        }
    }

    var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    func sharedInit() {
        addSubview(button)
        buttonType = .primary
    }

    func setClickTarget(_ target: Any, action: Selector) {
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(target, action: action, for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        let height = contentView.frame.size.height
        button.frame = CGRect(x: leftMargin, y: buttonType == .secondary ? 6 : 12, width: width, height: height - 12)
    }

    override func prepareForReuse() {
        button.removeTarget(nil, action: nil, for: .allEvents)
    }
}
