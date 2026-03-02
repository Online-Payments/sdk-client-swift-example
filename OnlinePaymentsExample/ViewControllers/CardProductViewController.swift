//
//  CardProductViewController.swift
//  OnlinePaymentsExample
//
//  Created for Online Payments on 18/04/2017.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import UIKit
import OnlinePaymentsKit

class CardProductViewController: PaymentProductViewController {

    var cobrands: [IINDetail] = []
    var previousEnteredCreditCardNumber: String = ""

    override func registerReuseIdentifiers() {
        super.registerReuseIdentifiers()
        tableView.register(
            CoBrandsSelectionTableViewCell.self,
            forCellReuseIdentifier: CoBrandsSelectionTableViewCell.reuseIdentifier
        )
        tableView.register(
            COBrandsExplanationTableViewCell.self,
            forCellReuseIdentifier: COBrandsExplanationTableViewCell.reuseIdentifier
        )
        tableView.register(
            PaymentProductTableViewCell.self,
            forCellReuseIdentifier: PaymentProductTableViewCell.reuseIdentifier
        )
    }

    override func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        super.updateTextFieldCell(cell: cell, row: row)

        // Add card logo for cardNumber field
        guard row.paymentProductField.id == "cardNumber" else {
            return
        }
        
        guard let productId = inputData.paymentProduct.id else {
            row.logo = nil
            cell.rightView = UIView()
            
            return
        }
        
        if confirmedPaymentProducts.contains(productId) {
            let prorductIconSize: CGFloat = 35.2
            let padding: CGFloat = 4.4
            
            let outerView = UIView(
                frame: CGRect(x: padding, y: padding, width: prorductIconSize, height: prorductIconSize)
            )
            
            let innerView = UIImageView(
                frame: CGRect(x: 0, y: 0, width: prorductIconSize, height: prorductIconSize)
            )
            
            innerView.contentMode = .scaleAspectFit
            innerView.image = row.logo
            
            outerView.addSubview(innerView)
            cell.rightView = outerView
        } else {
            row.logo = nil
            cell.rightView = UIView()
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]

        if (row is FormRowCoBrandsExplanation || row is PaymentProductsTableRow) && !row.isEnabled {
            return 0
        }

        if row is FormRowCoBrandsExplanation {
            let cellString = COBrandsExplanationTableViewCell.cellString()
            let rect =
                cellString.boundingRect(
                    with: CGSize(width: tableView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    context: nil
                )
            return rect.size.height + 20
        }

        if row is FormRowCoBrandsSelection {
            return 30
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        if let formRow = row as? FormRowCoBrandsSelection {
            return self.cell(for: formRow, tableView: tableView)
        }

        if let formRow = row as? FormRowCoBrandsExplanation {
            return self.cell(for: formRow, tableView: tableView)
        }

        if let formRow = row as? PaymentProductsTableRow {
            return self.cell(forPaymentProduct: formRow, tableView: tableView)
        }

        return super.formRowCell(for: row, indexPath: indexPath)
    }

    func cell(for _: FormRowCoBrandsSelection, tableView: UITableView) -> CoBrandsSelectionTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CoBrandsSelectionTableViewCell.reuseIdentifier
            ) as? CoBrandsSelectionTableViewCell
        else {
            fatalError("Could not cast cell to CoBrandsSelectionTableViewCell")
        }

        return cell
    }

    func cell(for _: FormRowCoBrandsExplanation, tableView: UITableView) -> COBrandsExplanationTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: COBrandsExplanationTableViewCell.reuseIdentifier
            ) as? COBrandsExplanationTableViewCell
        else {
            fatalError("Could not cast cell to COBrandsExplanationTableViewCell")
        }

        return cell
    }

    func cell(forPaymentProduct row: PaymentProductsTableRow, tableView: UITableView) -> PaymentProductTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: PaymentProductTableViewCell.reuseIdentifier
            ) as? PaymentProductTableViewCell
        else {
            fatalError("Could not cast cell to PaymentProductTableViewCell")
        }

        cell.name = row.name
        cell.logo = row.logo

        cell.accessoryType = .none
        cell.shouldHaveMaximalWidth = true
        cell.color = UIColor(white: 0.9, alpha: 1)
        cell.setNeedsLayout()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        if let row = formRows[indexPath.row] as? PaymentProductsTableRow,
           row.paymentProductIdentifier != self.paymentProduct.id {
            switchToPaymentProduct(paymentProductId: row.paymentProductIdentifier)
            return
        }

        if formRows[indexPath.row] is FormRowCoBrandsSelection || formRows[indexPath.row] is PaymentProductsTableRow {
            formRows = formRows.map {
                if $0 is FormRowCoBrandsExplanation || $0 is PaymentProductsTableRow {
                    $0.isEnabled = !$0.isEnabled
                }
                return $0
            }
            updateFormRows()
        }
    }

    override func updateFormRows() {
        if self.switching {

            // We need to update the tableView to the new amount of rows. However, we cannot use tableView.reloadData(),
            // because then the current textfield losses focus.
            // We also should not reload the cardNumber row with tableView.reloadRows([indexOfCardNumber, with: ...)
            // because that also makes the textfield lose focus.

            // Because the cardNumber field might move, we cannot just insert/delete the difference in rows in general,
            // because if we do, the index of the cardNumber field might change, and we cannot reload the new place.

            // So instead, we check the difference in rows before the cardNumber field
            // between before the mutation and after the mutation,
            // and the difference in rows after the cardNumber field between before and after the mutations

            tableView.beginUpdates()
            let oldFormRows = self.formRows
            self.initializeFormRows()
            self.addExtraRows()
            let oldCardNumberIndex = oldFormRows.firstIndex(where: { (row) -> Bool in
                (row as? FormRowTextField)?.paymentProductField.id == "cardNumber"
            }) ?? 0
            let newCardNumberIndex = self.formRows.firstIndex(where: { (row) -> Bool in
                (row as? FormRowTextField)?.paymentProductField.id == "cardNumber"
            })  ?? 0

            let diffCardNumberIndex = newCardNumberIndex - oldCardNumberIndex

            if diffCardNumberIndex >= 0 {
                let insertIndexes =
                    (0 ..< diffCardNumberIndex).map { (index) in
                        IndexPath(row: oldCardNumberIndex - 1 + index, section: 0)
                    }
                tableView.insertRows(at: insertIndexes, with: UITableView.RowAnimation.automatic)
                let updateIndexes = (0 ..< oldCardNumberIndex).map { (index) in IndexPath(row: index, section: 0) }
                tableView.reloadRows(at: updateIndexes, with: UITableView.RowAnimation.automatic)

            }
            if diffCardNumberIndex < 0 {
                let deleteIndexes = (0 ..< -diffCardNumberIndex).map { (index) in IndexPath(row: index, section: 0)}
                tableView.deleteRows(at: deleteIndexes, with: UITableView.RowAnimation.automatic)
                let updateIndexes =
                    (0 ..< oldCardNumberIndex + diffCardNumberIndex).map { (index) in
                        IndexPath(row: oldCardNumberIndex - index, section: 0)
                    }
                tableView.reloadRows(at: updateIndexes, with: UITableView.RowAnimation.automatic)
            }

            let oldAfterCardNumberCount = oldFormRows.count - oldCardNumberIndex - 1
            var newAfterCardNumberCount = formRows.count - newCardNumberIndex - 1

            let diffAfterCardNumberCount = newAfterCardNumberCount - oldAfterCardNumberCount
            if newAfterCardNumberCount < 0 {
                newAfterCardNumberCount = 0
            }
            if diffAfterCardNumberCount >= 0 {
                let insertIndexes =
                    (0 ..< diffAfterCardNumberCount).map { (index) in
                        IndexPath(row: oldFormRows.count + index, section: 0)
                    }
                tableView.insertRows(at: insertIndexes, with: UITableView.RowAnimation.automatic)
                let updateIndexes =
                    (0 ..< oldAfterCardNumberCount).map { (index) in
                        IndexPath(row: index + oldCardNumberIndex + 1, section: 0)
                    }
                tableView.reloadRows(at: updateIndexes, with: UITableView.RowAnimation.automatic)

            }
            if diffAfterCardNumberCount < 0 {
                let deleteIndexes =
                    (0 ..< -diffAfterCardNumberCount).map { (index) in
                        IndexPath(row: oldFormRows.count - index - 1, section: 0)
                    }
                tableView.deleteRows(at: deleteIndexes, with: UITableView.RowAnimation.automatic)
                let updateIndexes =
                    (0 ..< newAfterCardNumberCount).map { (index) in
                        IndexPath(row: self.formRows.count - index - 1 - diffCardNumberIndex, section: 0)
                    }
                tableView.reloadRows(at: updateIndexes, with: UITableView.RowAnimation.automatic)

            }

            tableView.endUpdates()
        }
        super.updateFormRows()
    }

    override func formatAndUpdateCharacters(textField: UITextField, cursorPosition: inout Int, indexPath: IndexPath) {
        super.formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)

        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }

        if row.paymentProductField.id == "cardNumber" {
            let unmasked = inputData.unmaskedValue(forField: row.paymentProductField.id)
            if unmasked.count >= 6, oneOfFirst8DigitsChangedIn(currentEnteredCreditCardNumber: unmasked) {
                sdk.iinDetails(
                    forPartialCardNumber: unmasked,
                    paymentContext: context,
                    success: {(_ response: IINDetailsResponse) -> Void in
                        guard
                          self.inputData.unmaskedValue(forField: row.paymentProductField.id).count >= 6 else {
                            return
                        }

                        self.switchToPaymentProduct(response: response)
                    },
                    failure: { _ in },
                )
            } else if unmasked.count < 6 {
                self.removeCoBrands()
            }
            previousEnteredCreditCardNumber = unmasked
        }
    }

    private func switchToPaymentProduct(response: IINDetailsResponse) {
        self.cobrands = response.coBrands
        
        if response.status == .supported {
            var coBrandSelected = false
            let coBrands = response.coBrands
            for cobrand in coBrands where cobrand.paymentProductId == self.paymentProduct.id {
                coBrandSelected = true
            }
            if !coBrandSelected {
                self.switchToPaymentProduct(paymentProductId: response.paymentProductId)
            } else {
                self.switchToPaymentProduct(paymentProductId: self.paymentProduct.id)
            }
        } else {
            self.switchToPaymentProduct(paymentProductId: self.initialPaymentProduct?.id)
        }
    }

    private func removeCoBrands() {
        // Remove cobrands
        var deleteRows = [IndexPath]()
        for (index, row) in self.formRows.enumerated() {
            if row is FormRowCoBrandsSelection ||
               row is FormRowCoBrandsExplanation ||
               row is PaymentProductsTableRow {
                deleteRows.append(IndexPath(row: index, section: 0))
            }
        }
        for indexPath in deleteRows.reversed() {
            self.formRows.remove(at: indexPath.row)
        }
        self.tableView.deleteRows(at: deleteRows, with: .none)
    }

    private func oneOfFirst8DigitsChangedIn(currentEnteredCreditCardNumber: String) -> Bool {
        return currentEnteredCreditCardNumber.prefix(8) != previousEnteredCreditCardNumber.prefix(8)
    }

    func coBrandForms(coBrandProducts: [PaymentProduct]) -> [FormRow] {
        
        var formRows = [FormRow]()

        if coBrandProducts.count > 1 {
            // Add explanation row
            let explanationRow = FormRowCoBrandsExplanation()
            formRows.append(explanationRow)

            // Add row for selection coBrands
            for product in coBrandProducts {
                let row = PaymentProductsTableRow()
                row.paymentProductIdentifier = product.id

                row.name = product.label
                row.logo = self.paymentProduct.getLogoImage()

                formRows.append(row)
            }

            let toggleCoBrandRow = FormRowCoBrandsSelection()
            formRows.append(toggleCoBrandRow)
        }

        return formRows
    }

    override func initializeFormRows() {
        super.initializeFormRows()
        var coBrandProducts = [PaymentProduct]()
        var count = self.cobrands.filter({$0.allowedInContext}).count
        for coBrand in self.cobrands where coBrand.allowedInContext {
            sdk.paymentProduct(
                withId: coBrand.paymentProductId,
                paymentContext: context,
                success: {(_ paymentProduct: PaymentProduct) -> Void in
                    coBrandProducts.append(paymentProduct)
                    count = count - 1
                    if (count < 1) {
                        let newFormRows = self.coBrandForms(coBrandProducts: coBrandProducts)
                        self.formRows.insert(contentsOf: newFormRows, at: 2)
                    }
                },
                failure: { _ in
                    count = count - 1
                }
            )
        }
        
    }
}
