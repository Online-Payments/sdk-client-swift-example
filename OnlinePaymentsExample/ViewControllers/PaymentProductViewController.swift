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
import UIKit
import OnlinePaymentsKit

class PaymentProductViewController: UITableViewController, UITextFieldDelegate,
                                    UIPickerViewDelegate, UIPickerViewDataSource,
                                    SwitchTableViewCellDelegate, DatePickerTableViewCellDelegate {

    var basicPaymentProduct: BasicPaymentProduct!
    var paymentProduct: PaymentProduct!
    var context: PaymentContext!
    var sdk: OnlinePaymentsSdk!
    var amount: Int = 0

    var header: SummaryTableHeaderView!
    var inputData: PaymentProductInputData!
    var confirmedPaymentProducts: Set<Int> = []
    var formRows: [FormRow] = []
    var initialPaymentProduct: PaymentProduct?

    var validation = false
    var rememberPaymentDetails = false
    var switching = false

    var paymentRequestTarget: PaymentRequestTarget?
    var accountOnFile: AccountOnFile?

    // MARK: - ViewController
    init(
        basicPaymentProduct: BasicPaymentProduct,
        paymentProduct: PaymentProduct,
        sdk: OnlinePaymentsSdk,
        context: PaymentContext,
        accountOnFile: AccountOnFile?
    ) {
        self.basicPaymentProduct = basicPaymentProduct
        self.paymentProduct = paymentProduct
        self.sdk = sdk
        self.context = context
        self.amount = context.amountOfMoney.amount
        self.accountOnFile = accountOnFile
        
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero

        view.backgroundColor = UIColor.white
        navigationItem.titleView = MerchantLogoImageView()

        rememberPaymentDetails = false

        initializeHeader()
        initializeTapRecognizer()

        inputData = PaymentProductInputData(
            paymentProduct: paymentProduct,
            accountOnFile: accountOnFile,
            tokenize: false
        )
        
        if let productId = paymentProduct.id {
            confirmedPaymentProducts.insert(productId)
        }
        
        initialPaymentProduct = paymentProduct
        initializeFormRows()
        addExtraRows()
        registerReuseIdentifiers()
    }

    func registerReuseIdentifiers() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.reuseIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
        tableView.register(
            PickerViewTableViewCell.self,
            forCellReuseIdentifier: PickerViewTableViewCell.reuseIdentifier
        )
        tableView.register(
            ErrorMessageTableViewCell.self,
            forCellReuseIdentifier: ErrorMessageTableViewCell.reuseIdentifier
        )
        tableView.register(TooltipTableViewCell.self, forCellReuseIdentifier: TooltipTableViewCell.reuseIdentifier)
        tableView.register(
            DatePickerTableViewCell.self,
            forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier
        )
    }

    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapScrollView)
    }

    @objc func tableViewTapped() {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {

            windowScene.windows.first(where: { $0.isKeyWindow })?.endEditing(true)
        }
    }

    func initializeHeader() {
        header = SummaryTableHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
        header.setSummary(
            summary:
                """
                \(NSLocalizedString(
                    "TotalText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Total of the shopping cart title"
                )):
                """
        )

        let amountAsNumber = (Double(amount) / Double(100)) as NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = context.amountOfMoney.currencyCode

        if let amountAsString = numberFormatter.string(from: amountAsNumber) {
            header.setAmount(amount: amountAsString)
        } else {
            header.setAmount(amount: "Error retrieving total amount")
        }
        header.setSecurePayment(
            securePayment:
                NSLocalizedString(
                    "SecurePaymentText",
                    tableName: AppConstants.kAppLocalizable,
                    bundle: AppConstants.appBundle,
                    value: "",
                    comment: "Text indicating that a secure payment method is used."
                )
        )
        tableView.tableHeaderView = header
    }
    
    func addExtraRows() {
        if basicPaymentProduct.allowsTokenization && accountOnFile == nil {
            // Add remember me switch
            let switchFormRow =
                FormRowSwitch(
                    title:
                        NSLocalizedString(
                            "RememberMeText",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: "Explanation of the switch for remembering payment information."
                        ),
                    isOn: rememberPaymentDetails,
                    target: self,
                    action: #selector(switchChanged),
                    paymentProductField: nil
                )
            switchFormRow.isEnabled = true
            self.formRows.append(switchFormRow)

            let switchFormRowTooltip = FormRowTooltip()
            switchFormRowTooltip.text =
                NSLocalizedString(
                    "RememberMeTooltip",
                    tableName: AppConstants.kAppLocalizable,
                    bundle: AppConstants.appBundle,
                    value: "",
                    comment: ""
                )
            switchFormRow.tooltip = switchFormRowTooltip
            self.formRows.append(switchFormRowTooltip)
        }

        // Add pay and cancel button
        let payButtonTitle =
            NSLocalizedString(
                "PayButtonText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Title of the pay button on the payment product screen."
            )
        let payButtonFormRow = FormRowButton(title: payButtonTitle, target: self, action: #selector(payButtonTapped))
        
        payButtonFormRow.isEnabled = true
        formRows.append(payButtonFormRow)
        
        let cancelButtonTitle =
            NSLocalizedString(
                "CancelButtonText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Title of the cancel button on the payment product screen."
            )
        let cancelButtonFormRow =
            FormRowButton(title: cancelButtonTitle, target: self, action: #selector(cancelButtonTapped))
        cancelButtonFormRow.buttonType = .secondary
        cancelButtonFormRow.isEnabled = true
        self.formRows.append(cancelButtonFormRow)
    }

    func initializeFormRows() {
        let mapper = FormRowsConverter()
        let formRows = mapper.formRows(from: inputData, confirmedPaymentProducts: confirmedPaymentProducts)

        var formRowsWithTooltip = [FormRow]()
        for row in formRows {
            formRowsWithTooltip.append(row)
            if let infoButtonRow = row as? FormRowWithInfoButton, let tooltipRow = infoButtonRow.tooltip {
                formRowsWithTooltip.append(tooltipRow)
            }
        }

        self.formRows = formRowsWithTooltip
    }

    func updateFormRows() {
        tableView.beginUpdates()
        for (index, row) in formRows.enumerated() {
            if let row = row as? FormRowTextField,
               let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TextFieldTableViewCell {
                updateTextFieldCell(cell: cell, row: row)
            } else if let row = row as? FormRowSwitch {
                if row.action == #selector(switchChanged) {
                    if basicPaymentProduct.allowsTokenization && accountOnFile == nil {
                        row.isEnabled = true
                    } else {
                        row.isEnabled = false
                    }
                }
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SwitchTableViewCell {
                    updateSwitchCell(cell, row: row)
                }

            } else if let row = row as? FormRowButton,
                      row.action == #selector(payButtonTapped),
                      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ButtonTableViewCell {
                
                row.isEnabled = true
                updateButtonCell(cell: cell, row: row)
            }
        }
        tableView.endUpdates()
    }

    func updateButtonCell(cell: ButtonTableViewCell, row: FormRowButton) {
        cell.isEnabled = row.isEnabled
    }

    func switchToPaymentProduct(paymentProductId: Int?) {
        if let paymentProductId = paymentProductId {
            confirmedPaymentProducts.insert(paymentProductId)
        } else {
            if let currentId = paymentProductId {
                confirmedPaymentProducts.remove(currentId)
            }
            
            updateFormRows()
        }
        if let currentId = paymentProductId, paymentProductId == currentId {
            updateFormRows()
            
            return
        } else if let paymentProductId = paymentProductId, !switching {
            switching = true
            sdk.paymentProduct(
                withId: paymentProductId,
                paymentContext: context,
                success: {(newProduct: PaymentProduct) -> Void in
                    self.paymentProduct = newProduct
                    self.inputData.paymentProduct = newProduct
                    self.updateFormRows()
                    self.switching = false
                },
                failure: { _ in },
            )
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = formRows[indexPath.row]
        let cell = formRowCell(for: row, indexPath: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowTextField {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowCurrency {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowSwitch {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowList {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowButton {
            cell = self.cell(for: formRow, tableView: tableView)
        }
            // Should be before FormRowLabel due to inheritance
        else if let formRow = row as? FormRowErrorMessage {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowLabel {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowTooltip {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowDate {
            cell = self.cell(for: formRow, tableView: tableView)
        } else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid form row class"),
                reason: "Form row class is invalid", userInfo: nil
            ).raise()
        }

        guard let cell = cell
        else {
            let emptyCell = TableViewCell()
            return emptyCell
        }

        cell.clipsToBounds = true
        return cell
    }

    func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        // Add error messages for cells
        cell.delegate = self
        cell.accessoryType = row.showInfoButton ? .detailButton : .none
        cell.readonly = !row.isEnabled
        cell.field = row.field

        let currentValue = row.field.text
        let errors = row.paymentProductField.validate(value: currentValue)
        
        cell.error = errors.first?.errorMessage
    }

    func cell(for row: FormRowTextField, tableView: UITableView) -> TextFieldTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier) as? TextFieldTableViewCell
        else {
              fatalError("Could not cast cell to TextFieldTableViewCell")
        }

        self.updateTextFieldCell(cell: cell, row: row)

        return cell
    }

    func cell(for row: FormRowDate, tableView: UITableView) -> DatePickerTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: DatePickerTableViewCell.reuseIdentifier
            ) as? DatePickerTableViewCell else {
              fatalError("Could not cast cell to DatePickerTableViewCell")
        }

        cell.readonly = !row.isEnabled
        cell.date = row.date

        cell.delegate = self

        return cell
    }

    func cell(for row: FormRowCurrency, tableView: UITableView) -> CurrencyTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CurrencyTableViewCell.reuseIdentifier
            ) as? CurrencyTableViewCell else {
              fatalError("Could not cast cell to CurrencyTableViewCell")
        }

        cell.delegate = self
        cell.integerField = row.integerField
        cell.fractionalField = row.fractionalField
        cell.readonly = !row.isEnabled
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }

    func cell(for row: FormRowSwitch, tableView: UITableView) -> SwitchTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.reuseIdentifier
            ) as? SwitchTableViewCell else {
              fatalError("Could not cast cell to SwitchTableViewCell")
        }

        cell.setSwitchTarget(row.target, action: row.action)
        cell.delegate = self
        cell.isOn = row.isOn
        cell.attributedTitle = row.title
        cell.readonly = !row.isEnabled
        cell.accessoryType = row.showInfoButton ? .detailButton : .none
        
        if validation, let field = row.field {
            let value = row.isOn ? "true" : "false"
            let errors = field.validate(value: value)
            cell.errorMessage = errors.first?.errorMessage
        } else {
            cell.errorMessage = nil
        }

        return cell
    }

    func cell(for row: FormRowList, tableView: UITableView) -> PickerViewTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: PickerViewTableViewCell.reuseIdentifier
            ) as? PickerViewTableViewCell else {
              fatalError("Could not cast cell to PickerViewTableViewCell")
        }

        cell.delegate = self
        cell.dataSource = self
        cell.selectedRow = row.selectedRow
        cell.readonly = !row.isEnabled

        return cell
    }

    func cell(for row: FormRowButton, tableView: UITableView) -> ButtonTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ButtonTableViewCell.reuseIdentifier
            ) as? ButtonTableViewCell else {
              fatalError("Could not cast cell to ButtonTableViewCell")
        }

        cell.setClickTarget(row.target, action: row.action)
        cell.title = row.title
        cell.buttonType = row.buttonType
        cell.isEnabled = row.isEnabled
        return cell
    }

    func cell(for row: FormRowLabel, tableView: UITableView) -> LabelTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: LabelTableViewCell.reuseIdentifier
            ) as? LabelTableViewCell else {
              fatalError("Could not cast cell to LabelTableViewCell")
        }

        cell.label = row.text
        cell.isBold = row.isBold
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }

    func cell(for row: FormRowErrorMessage, tableView: UITableView) -> ErrorMessageTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ErrorMessageTableViewCell.reuseIdentifier
            ) as? ErrorMessageTableViewCell else {
              fatalError("Could not cast cell to ErrorMessageTableViewCell")
        }

        cell.label = row.text

        return cell
    }

    func cell(for row: FormRowTooltip, tableView: UITableView) -> TooltipTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: TooltipTableViewCell.reuseIdentifier
            ) as? TooltipTableViewCell else {
              fatalError("Could not cast cell to TooltipTableViewCell")
        }

        cell.tooltipImage = row.image
        cell.label = row.text

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]

        if row is FormRowList {
            return DatePickerTableViewCell.pickerHeight
        }
        if row is FormRowDate {
            return DatePickerTableViewCell.pickerHeight
        }

        // Rows that you can toggle
        else if row is FormRowTooltip, !row.isEnabled {
            return 0
        } else if let row = row as? FormRowSwitch, row.action == #selector(switchChanged), !row.isEnabled {
            return 0
        } else if let row = row as? FormRowTooltip, row.image != nil {
            return 145
        } else if let row = row as? FormRowTooltip {
            return TooltipTableViewCell.cellSize(width: min(320, tableView.frame.width), formRow: row).height
        } else if let row = row as? FormRowLabel {
            let height = LabelTableViewCell.cellSize(width: min(320, tableView.frame.width), formRow: row).height
            return height
        } else if row is FormRowButton {
            return 52
        } else if let row = row as? FormRowTextField, validation {
            let value = inputData.unmaskedValue(forField: row.paymentProductField.id)
            let errors = row.paymentProductField.validate(value: value)
            
            if let error = errors.first {
                return self.getTextFieldErrorRowHeight(
                    tableView: tableView,
                    row: row,
                    error: error.errorMessage
                )
            }
        } else if let row = row as? FormRowSwitch {
            return self.getSwitchRowHeight(tableView: tableView, row: row)
        }

        return 44
    }

    private func getTextFieldErrorRowHeight(
        tableView: UITableView,
        row: FormRowTextField,
        error: String
    ) -> CGFloat {
        var width = tableView.bounds.width - 20
        if row.showInfoButton {
            width -= 48
        }
        let str = NSAttributedString(string: error)

        return
            44 + str.boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                context: nil
            ).height
    }

    private func getSwitchRowHeight(tableView: UITableView, row: FormRowSwitch) -> CGFloat {
        var width = tableView.bounds.width - 20
        if row.showInfoButton {
            width -= 48
        }
        var errorHeight: CGFloat = 0
        if validation, let field = row.field {
            let value = row.isOn ? "true" : "false"
            let errors = field.validate(value: value)
            
            if let firstError = errors.first {
                let str = NSAttributedString(string: firstError.errorMessage)
                errorHeight = str.boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                ).height + 10
            }
        }
        
        return 10 + 44 + 10 + errorHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Subclasses need to be able to call this method to prevent unrecognized selector exception so don't delete it!
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let formRow = formRows[indexPath.row + 1] as? FormRowTooltip {
            formRow.isEnabled = !formRow.isEnabled

            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    // MARK: - TextField delegate

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        var returnValue = false
        if let castedTextField = textField as? IntegerTextField {
            returnValue = integerTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        } else if let castedTextField = textField as? FractionalTextField {
            returnValue =
                fractionalTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        } else if let castedTextField = textField as? TextField {
            returnValue = standardTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        }
        if validation {
            validateData()
        }

        return returnValue
    }

    func standardTextField(
        _ textField: TextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let row = formRows[indexPath.row] as? FormRowTextField,
              let text = textField.text else {
            return false
        }

        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        inputData.setValue(value: newString, forField: row.paymentProductField.id)
        var field = row.field
        field.text = inputData.maskedValue(forField: row.paymentProductField.id)
        row.field = field
        formRows[indexPath.row] = row

        var cursorPosition = range.location + string.count
        formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)

        return false
    }

    func formatAndUpdateCharacters(textField: UITextField, cursorPosition: inout Int, indexPath: IndexPath) {
        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }

        let trimSet = CharacterSet(charactersIn: " /-_")
        let formattedString =
            inputData.maskedValue(
                forField: row.paymentProductField.id,
                cursorPosition: &cursorPosition
            ).trimmingCharacters(in: trimSet)
        row.field.text = formattedString
        textField.text = formattedString
        cursorPosition = min(cursorPosition, formattedString.count)

        guard let cursorPositionInTextField =
                textField.position(from: textField.beginningOfDocument, offset: cursorPosition) else {
            return
        }
        textField.selectedTextRange =
            textField.textRange(from: cursorPositionInTextField, to: cursorPositionInTextField)

    }

    func integerTextField(
        _ textField: IntegerTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency,
            let text = textField.text else {
            return false
        }

        let integerString = (text as NSString).replacingCharacters(in: range, with: string)

        if integerString.count > 16 {
            return false
        }

        if string.count == 0 {
            return true
        }

        guard let fractionalString = cell.fractionalTextField.text else {
            return false
        }

        let newValue =
            updateCurrencyValue(
                withIntegerString: integerString,
                fractionalString: fractionalString,
                paymentProductFieldIdentifier: row.paymentProductField.id
            )
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }

    func fractionalTextField(
        _ textField: FractionalTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency,
            let text = textField.text else {
            return false
        }

        var fractionalString = (text as NSString).replacingCharacters(in: range, with: string)

        if fractionalString.count > 2 {
            let end = fractionalString.endIndex
            let start = fractionalString.index(end, offsetBy: -2)
            fractionalString = String(fractionalString[start..<end])
        }

        if string.count == 0 {
            return true
        }

        guard let integerString = cell.integerTextField.text else {
            return false
        }

        let newValue =
            updateCurrencyValue(
                withIntegerString: integerString,
                fractionalString: fractionalString,
                paymentProductFieldIdentifier: row.paymentProductField.id
            )
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }

    func updateCurrencyValue(
        withIntegerString integerString: String,
        fractionalString: String,
        paymentProductFieldIdentifier identifier: String
    ) -> String {
        let integerPart = Int(integerString) ?? 0
        let fractionalPart = Int(fractionalString) ?? 0
        let newValue = integerPart * 100 + fractionalPart
        let newString = String(format: "%03lld", newValue)
        inputData.setValue(value: newString, forField: identifier)

        return newString
    }

    func updateRow(withCurrencyValue currencyValue: String, forCell cell: CurrencyTableViewCell) {
        cell.integerTextField.text = String(currencyValue.dropLast(2))
        cell.fractionalTextField.text = String(currencyValue.suffix(2))
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }

    // MARK: - Picker view delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let picker = pickerView as? PickerView else {
            fatalError("Could not cast picker to PickerView")
        }
        return picker.content.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int, forComponent component: Int
    ) -> NSAttributedString? {
        guard let picker = pickerView as? PickerView
        else {
            fatalError("Could not cast picker to PickerView")
        }

        let item = picker.content[row]

        return NSAttributedString(string: item)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let cell = pickerView.superview as? PickerViewTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let formRow = formRows[indexPath.row] as? FormRowList
        else {
            return
        }

        formRow.selectedRow = 0
    }

    func validateData() {
        inputData.validate()
        updateFormRows()
    }

    // MARK: - Button target methods

    @objc func payButtonTapped() {
        var valid = false
        inputData.validate()
        
        if inputData.errors.count == 0 {
            inputData.createPaymentRequest()
            
            guard let paymenRequest = inputData.paymentRequest else {
                validation = true
                updateFormRows()
                
                return
            }
            
            do {
                let result = try paymenRequest.validate()
                if result.isValid {
                    valid = true
                    paymentRequestTarget?.didSubmitPaymentRequest(paymentRequest: paymenRequest)
                }
            } catch {
                valid = false
            }
        }
        
        if !valid {
            validation = true
            updateFormRows()
        }
    }

    @objc func cancelButtonTapped() {
        paymentRequestTarget?.didCancelPaymentRequest()
    }

    func updateSwitchCell(_ cell: SwitchTableViewCell, row: FormRowSwitch) {
        guard let field = row.field else {
            return
        }

        let value = inputData.unmaskedValue(forField: field.id)
        let errors = field.validate(value: value)
    }

    func datePicker(_ datePicker: UIDatePicker, selectedNewDate date: Date) {
        guard let cell = datePicker.superview as? DatePickerTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let row = formRows[indexPath.row] as? FormRowDate else {
            return
        }
        row.date = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        inputData.setValue(value: formatter.string(from: date), forField: row.paymentProductField.id)

    }

    @objc func switchChanged(_ sender: Switch) {

        guard let cell = sender.superview as? SwitchTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let row = formRows[indexPath.row] as? FormRowSwitch else {
            return
        }
        let field = row.field

        if let field = field {
            inputData.setValue(value: sender.isOn ? "true" : "false", forField: field.id)
            row.isOn = sender.isOn
            if validation {
                validateData()
            }
            updateSwitchCell(cell, row: row)
        } else {
            inputData.tokenize = sender.isOn
        }
    }

}
