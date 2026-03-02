//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 04/08/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation
import OnlinePaymentsKit
import UIKit

class FormRowsConverter {

    func formRows(from inputData: PaymentProductInputData, confirmedPaymentProducts: Set<Int>) -> [FormRow] {
        var rows: [FormRow] = []
        let paymentProductFields = inputData.paymentProduct.fields

        for field in paymentProductFields {
            let isPartOfAccountOnFile = inputData.fieldIsPartOfAccountOnFile(paymentProductFieldId: field.id)
            let value: String
            let isEnabled: Bool

            if isPartOfAccountOnFile {
                let rawValue = inputData.accountOnFile?.getValue(id: field.id) ?? ""
                value = field.applyMask(value: rawValue) ?? rawValue
                isEnabled = !inputData.fieldIsReadOnly(paymentProductFieldId: field.id)
            } else {
                value = inputData.maskedValue(forField: field.id)
                isEnabled = true
            }

            var row: FormRow = labelFormRow(from: field)
            rows.append(row)

            switch field.displayHints.formElement.type {
            case .listType:
                row = listFormRow(from: field, value: value, isEnabled: isEnabled)
            case .textType:
                row = textFieldFormRow(
                    from: field,
                    inputData: inputData,
                    value: value,
                    isEnabled: isEnabled,
                    confirmedPaymentProducts: confirmedPaymentProducts
                )
            case .currencyType:
                row = currencyFormRow(from: field, value: value, isEnabled: isEnabled)
            case .dateType:
                row = dateFormRow(from: field, value: value, isEnabled: isEnabled)
            case .boolType:
                rows.removeLast()
                row = switchFormRow(from: field, value: value, isEnabled: isEnabled)
            }

            rows.append(row)
        }

        return rows
    }

    func textFieldFormRow(
        from field: PaymentProductField,
        inputData: PaymentProductInputData,
        value: String,
        isEnabled: Bool,
        confirmedPaymentProducts: Set<Int>?
    ) -> FormRowTextField {
        // Set placeholder for field
        let placeholderValue = field.displayHints.placeholderLabel ?? "No placeholder found"

        let keyboardType: UIKeyboardType
        switch field.displayHints.preferredInputType {
        case .integerKeyboard:
            keyboardType = .numberPad

        case .emailAddressKeyboard:
            keyboardType = .emailAddress

        case .phoneNumberKeyboard:
            keyboardType = .phonePad

        case .stringKeyboard, .dateKeyboard:
            keyboardType = .default
        }

        let formField =
            FormRowField(
                text: value,
                placeholder: placeholderValue,
                keyboardType: keyboardType,
                isSecure: field.displayHints.obfuscate
            )
        let row = FormRowTextField(paymentProductField: field, field: formField)
        row.isEnabled = isEnabled

        if field.id == "cardNumber" {
            if let confirmedPaymentProducts,
               let productId = inputData.paymentProduct.id,
               confirmedPaymentProducts.contains(productId) {
                row.logo = inputData.paymentProduct.getLogoImage()
            } else {
                row.logo = nil
            }
        }

        setTooltipForFormRow(row, with: field)

        return row
    }

    func currencyFormRow(from field: PaymentProductField, value: String, isEnabled: Bool) -> FormRowCurrency {
        // Set placeholder for field (response only returns empty placeholder labels)
        let placeholderValue = field.displayHints.placeholderLabel ?? "No placeholder found"

        let keyboardType: UIKeyboardType
        switch field.displayHints.preferredInputType {
        case .integerKeyboard:
            keyboardType = .numberPad
        case .emailAddressKeyboard:
            keyboardType = .emailAddress
        case .phoneNumberKeyboard:
            keyboardType = .phonePad
        case .stringKeyboard, .dateKeyboard:
            keyboardType = .default
        }

        let integerPart = Int((Double(value) ?? 0) / 100)
        let fractionalPart = Int(llabs((Int64(value) ?? 0) % 100))

        let integerField =
            FormRowField(
                text: "\(integerPart)",
                placeholder: placeholderValue,
                keyboardType: keyboardType,
                isSecure: field.displayHints.obfuscate
            )
        let fractionalField =
            FormRowField(
                text: String(format: "%02d", fractionalPart),
                placeholder: "",
                keyboardType: keyboardType,
                isSecure: field.displayHints.obfuscate
            )

        let row =
            FormRowCurrency(paymentProductField: field, integerField: integerField, fractionalField: fractionalField)

        row.integerField = integerField
        row.fractionalField = fractionalField
        row.isEnabled = isEnabled

        setTooltipForFormRow(row, with: field)

        return row
    }

    func switchFormRow(
        from field: PaymentProductField,
        value: String,
        isEnabled: Bool
    ) -> FormRowSwitch {
        let descriptionKey = String(format: "PaymentProductField.%@.label", field.id)

        let descriptionValue = NSLocalizedString(
            descriptionKey,
            tableName: AppConstants.kAppLocalizable,
            bundle: AppConstants.appBundle,
            value: "",
            comment: ""
        )
        
        let attrString = NSMutableAttributedString(string: descriptionValue)
        
        let row = FormRowSwitch(title: attrString, isOn: value == "true", target: nil, action: nil, paymentProductField: field)
        
        row.isEnabled = isEnabled
        return row
    }

    func dateFormRow(from field: PaymentProductField, value: String, isEnabled: Bool) -> FormRowDate {
        let row = FormRowDate(paymentProductField: field, value: value)
        row.isEnabled = isEnabled

        return row
    }

    func setTooltipForFormRow(_ row: FormRowWithInfoButton, with field: PaymentProductField) {
        // Only create a tooltip when the label is not empty
        if let tooltipLabel = field.displayHints.tooltip?.label,
               !tooltipLabel.isEmpty {
            let tooltip = FormRowTooltip()
            tooltip.text = field.displayHints.tooltip?.label
            row.tooltip = tooltip
        }
    }

    func listFormRow(from field: PaymentProductField, value: String, isEnabled: Bool) -> FormRowList {
        let row = FormRowList(paymentProductField: field)

        row.selectedRow = 0
        row.isEnabled = isEnabled

        return row
    }

    func labelFormRow(from field: PaymentProductField) -> FormRowLabel {
        let labelValue = field.displayHints.label ?? "No label found"

        return FormRowLabel(text: labelValue)
    }
}
