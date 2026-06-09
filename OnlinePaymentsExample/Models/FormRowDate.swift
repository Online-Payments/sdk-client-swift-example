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

class FormRowDate: FormRow {

    var paymentProductField: PaymentProductField
    var date: Date
    init(paymentProductField field: PaymentProductField, value: String) {
        if value != "" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"

            date = formatter.date(from: value) ?? Date()

        } else {
            date = Date()
        }

        self.paymentProductField = field
    }

}
