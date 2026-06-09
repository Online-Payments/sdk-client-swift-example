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

struct FormRowField {
    var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var isSecure: Bool
}

class FormRowTextField: FormRowWithInfoButton {
    var paymentProductField: PaymentProductField
    var logo: UIImage?
    var field: FormRowField

    init(paymentProductField: PaymentProductField, field: FormRowField) {
        self.paymentProductField = paymentProductField
        self.field = field
    }
}
