//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 04/08/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation
import OnlinePaymentsKit

class TableSectionConverter {
    static func paymentProductsTableSectionFromAccounts(
        onFile accountsOnFile: [AccountOnFile],
        basicPaymentProducts: BasicPaymentProducts
    ) -> PaymentProductsTableSection {

        let section = PaymentProductsTableSection()
        section.type = .gcAccountOnFileType
        
        let sortedAccounts = accountsOnFile.sorted { a, b in
            let displayOrderA = parentProduct(for: a, in: basicPaymentProducts)?.displayOrder ?? Int.max
            let displayOrderB = parentProduct(for: b, in: basicPaymentProducts)?.displayOrder ?? Int.max
            return displayOrderA < displayOrderB
        }

        for accountOnFile in sortedAccounts {
            guard let product = parentProduct(for: accountOnFile, in: basicPaymentProducts) else {
                continue
            }
            
            let row = PaymentProductsTableRow()
            row.name = accountOnFile.label
            row.accountOnFileIdentifier = accountOnFile.id
            
            row.paymentProductIdentifier = accountOnFile.paymentProductId
            row.logo = product.getLogoImage()
            
            section.rows.append(row)
        }

        return section
    }

    static func paymentProductsTableSection(from basicPaymentProducts: BasicPaymentProducts) -> PaymentProductsTableSection {
        let section = PaymentProductsTableSection()
        
        let sortedPaymentProducts = basicPaymentProducts.paymentProducts.sorted { a, b in
            if a.displayOrder != b.displayOrder {
                return a.displayOrder < b.displayOrder
            }
            
            return (a.id ?? Int.max) < (b.id ?? Int.max)
        }
        
        for product in sortedPaymentProducts {
            let row = PaymentProductsTableRow()
            
            row.name = product.label ?? ""
            
            row.accountOnFileIdentifier = ""
            row.paymentProductIdentifier = product.id ?? 0
            row.logo = product.getLogoImage()
            
            section.rows.append(row)
        }

        return section
    }
    
    private static func parentProduct(
        for account: AccountOnFile,
        in basicPaymentProducts: BasicPaymentProducts
    ) -> BasicPaymentProduct? {
        return basicPaymentProducts.paymentProducts.first{ product in
            product.accountsOnFile.contains(where: { $0.id == account.id })
        }
    }
}
