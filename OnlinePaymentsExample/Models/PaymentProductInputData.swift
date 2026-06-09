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

class PaymentProductInputData {
    var paymentProduct: PaymentProduct!
    var accountOnFile: AccountOnFile!
    var tokenize = false
    var errors = NSMutableArray()
    var fieldValues: [String: String] = [:]
    let formatter = StringFormatter()
    var paymentRequest: PaymentRequest?
    
    init(
        paymentProduct: PaymentProduct,
        accountOnFile: AccountOnFile? = nil,
        tokenize: Bool = false
    ) {
        self.paymentProduct = paymentProduct
        self.accountOnFile = accountOnFile
        self.tokenize = tokenize
    }
    
    func createPaymentRequest() {
        let request = PaymentRequest (
            paymentProduct: paymentProduct,
            accountOnFile: accountOnFile,
            tokenize: tokenize)
        
        for (fieldId, _) in fieldValues {
            let value = unmaskedValue(forField: fieldId)
            
            do {
                try request.setValue(id: fieldId, value: value)
            } catch {
                
            }
        }
        
        paymentRequest = request
    }

    func setValue(value: String, forField paymentProductFieldId: String) {
        fieldValues[paymentProductFieldId] = value
    }

    func value(forField paymentProductFieldId: String) -> String {
        guard let value = fieldValues[paymentProductFieldId] else {
            return ""
        }

        return value
    }

    func maskedValue(forField paymentProductFieldId: String) -> String {
        var cursorPosition = 0
        return maskedValue(forField: paymentProductFieldId, cursorPosition: &cursorPosition)
    }

    func maskedValue(forField paymentProductFieldId: String, cursorPosition: inout Int) -> String {
        let value = self.value(forField: paymentProductFieldId)
        guard let maskValue = mask(forField: paymentProductFieldId) else {
            return value
        }

        return formatter.formatString(string: value, mask: maskValue, cursorPosition: &cursorPosition)
    }

    func unmaskedValue(forField paymentProductFieldId: String) -> String {
        let value = self.value(forField: paymentProductFieldId)
        guard let maskValue = mask(forField: paymentProductFieldId) else {
            return value
        }

        return formatter.unformatString(string: value, mask: maskValue)

    }

    func fieldIsPartOfAccountOnFile(paymentProductFieldId: String) -> Bool {
        return accountOnFile?.getValue(id: paymentProductFieldId) != nil
    }

    func fieldIsReadOnly(paymentProductFieldId: String) -> Bool {
        guard let accountOnFile else {
            return false
        }
        
        return !accountOnFile.isWritable(id: paymentProductFieldId)
    }

    func mask(forField paymentProductFieldId: String) -> String? {
        return paymentProduct.field(id: paymentProductFieldId)?.displayHints.mask
    }

    func validateExcept(fieldNames exceptFieldNames: Set<String>) {
        errors.removeAllObjects()

        for field in paymentProduct.fields where !fieldIsPartOfAccountOnFile(paymentProductFieldId: field.id) {
            if unmaskedValue(forField: field.id).isEmpty {
                setDefaultValue(for: field)
            }
            
            if exceptFieldNames.contains(field.id) {
                continue
            }
            
            let fieldValue = unmaskedValue(forField: field.id)
            let validationErrors = field.validate(value: fieldValue)
            errors.addObjects(from: validationErrors)
        }
    }

    func validate() {
        self.validateExcept(fieldNames: Set())
    }

    private func setDefaultValue(for field: PaymentProductField) {
        // It's not possible to choose an empty string with a date picker
        // If not set, we assume the first is chosen
        if field.type == .dateString {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            setValue(value: formatter.string(from: Date()), forField: field.id)
        }

        // It's not possible to choose an empty boolean with a switch
        // If not set, we assume false is chosen
        if field.type == .boolString {
            setValue(value: "false", forField: field.id)
        }
    }
}
