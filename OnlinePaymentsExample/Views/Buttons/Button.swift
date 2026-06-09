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

enum ExampleButtonType {
    case primary
    case secondary
    case destructive
}

class Button: UIButton {

    init(type: ExampleButtonType = .primary) {
        self.exampleButtonType = type
        super.init(frame: .zero)

        self.configuration = UIButton.Configuration.plain()
        self.configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 12,
            bottom: 8,
            trailing: 12
        )

        layer.cornerRadius = 5
        self.setButtonType()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var exampleButtonType: ExampleButtonType {
        didSet {
            self.setButtonType()
        }
    }

    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            alpha = newValue ? 1 : 0.3
        }
    }

    private func setButtonType() {
        switch exampleButtonType {
        case .primary:
            setTitleColor(UIColor.white, for: .normal)
            setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            backgroundColor = AppConstants.kPrimaryColor
            setFont(.bold)

        case .secondary:
            setTitleColor(UIColor.systemBlue, for: .normal)
            setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: .highlighted)
            backgroundColor = AppConstants.kSecondaryColor
            setFont(.regular)

        case .destructive:
            setTitleColor(UIColor.white, for: .normal)
            setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            backgroundColor = AppConstants.kDestructiveColor
            setFont(.bold)
        }
    }

    private func setFont(_ weight: UIFont.Weight) {
        configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: weight)
            return outgoing
        }
    }
}
