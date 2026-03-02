//
//  PaymentProductsViewController.swift
//  OnlinePaymentsExample
//
//  Created for Online Payments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit
import OnlinePaymentsKit

class PaymentProductsViewController: UITableViewController {

    let basicPaymentProducts: BasicPaymentProducts

    var target: PaymentProductSelectionTarget?
    var amount = 0
    var currencyCode = ""

    var sections = [PaymentProductsTableSection]()
    var header: SummaryTableHeaderView!

    init(style: UITableView.Style, basicPaymentProducts: BasicPaymentProducts) {
        self.basicPaymentProducts = basicPaymentProducts
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.titleView = MerchantLogoImageView()
        initializeHeader()
        
        buildSections()
        
        tableView.register(
            PaymentProductTableViewCell.self,
            forCellReuseIdentifier: PaymentProductTableViewCell.reuseIdentifier
        )
    }
    
    private func buildSections() {
        sections.removeAll()
        
        let accountsOnFile: [AccountOnFile] =
            basicPaymentProducts.paymentProducts.flatMap { $0.accountsOnFile }
        
        if !accountsOnFile.isEmpty {
            let accountsSection = TableSectionConverter.paymentProductsTableSectionFromAccounts(
                onFile: accountsOnFile,
                basicPaymentProducts: basicPaymentProducts
            )
            
            accountsSection.title = NSLocalizedString(
                "AccountsOnFileTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Title for the section that displays stored payment products"
            )
            
            sections.append(accountsSection)
        }
        
        let productsSections = TableSectionConverter.paymentProductsTableSection(from: basicPaymentProducts)
        productsSections.type = .gcPaymentProductType
        productsSections.title = NSLocalizedString(
            "SelectPaymentProductText",
            tableName: AppConstants.kAppLocalizable,
            bundle: AppConstants.appBundle,
            value: "",
            comment: "Title of the section that shows all available payment products"
        )
        
        sections.append(productsSections)
    }

    func initializeHeader() {
        header = SummaryTableHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
        let totalLabel =
            NSLocalizedString(
                "TotalText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Total of the shopping cart title"
            )
        header.setSummary(summary: "\(totalLabel):")

        let amountAsNumber = (Double(amount) / Double(100)) as NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode

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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(
                        withIdentifier: PaymentProductTableViewCell.reuseIdentifier
                ) as? PaymentProductTableViewCell else {
            fatalError("Could not cast cell to PaymentProductTableViewCell")
        }
        
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.name = row.name
        cell.logo = row.logo
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        guard let product = basicPaymentProducts.paymentProducts.first(where: { $0.id == row.paymentProductIdentifier}) else {
            tableView.deselectRow(at: indexPath, animated: true)
            
            return
        }
        
        if section.type == .gcAccountOnFileType {
            let accountOnFile = product.accountOnFile(withIdentifier: row.accountOnFileIdentifier)
            target?.didSelect(paymentProduct: product, accountOnFile: accountOnFile)
        } else {
            target?.didSelect(paymentProduct: product, accountOnFile: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
