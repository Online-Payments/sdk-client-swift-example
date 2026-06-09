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

import Foundation
import OnlinePaymentsKit

class FormRowSwitch: FormRowWithInfoButton {
    var isOn: Bool
    var title: NSAttributedString
    var target: Any?
    var action: Selector?
    var field: PaymentProductField?

    init(
        title: NSAttributedString,
        isOn: Bool,
        target: Any?,
        action: Selector?,
        paymentProductField field: PaymentProductField?
    ) {
        self.title = title
        self.isOn = isOn
        self.target = target
        self.action = action
        self.field = field
    }

    convenience init(
        title: String,
        isOn: Bool,
        target: Any?,
        action: Selector?,
        paymentProductField field: PaymentProductField?
    ) {
        self.init(
            title: NSAttributedString(string: title),
            isOn: isOn,
            target: target,
            action: action,
            paymentProductField: field
        )
    }
}
