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

class EndViewController: UIViewController {

    var encryptedCustomerInput: String!
    var target: ContinueShoppingTarget!

    init(encryptedCustomerInput: String) {
        self.encryptedCustomerInput = encryptedCustomerInput
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.encryptedCustomerInput = ""
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        view.backgroundColor = UIColor.white

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)

        var constraint =
            NSLayoutConstraint(
                item: container,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 500
            )
        container.addConstraint(constraint)
        constraint =
            NSLayoutConstraint(
                item: container,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 380
            )
        container.addConstraint(constraint)
        constraint =
            NSLayoutConstraint(
                item: container,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        view.addConstraint(constraint)
        constraint =
            NSLayoutConstraint(
                item: container,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .top,
                multiplier: 1,
                constant: 20
            )
        view.addConstraint(constraint)

        let label = UILabel()
        container.addSubview(label)
        label.textAlignment = .center
        label.text =
            NSLocalizedString(
                "SuccessTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        label.translatesAutoresizingMaskIntoConstraints = false

        let textView = UITextView()
        container.addSubview(textView)
        textView.textAlignment = .center
        textView.text =
            NSLocalizedString(
                "SuccessText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 0.85, green: 0.94, blue: 0.97, alpha: 1)
        textView.textColor = UIColor(red: 0, green: 0.58, blue: 0.82, alpha: 1)
        textView.layer.cornerRadius = 5.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false

        let encryptedString = UITextView()
        encryptedString.translatesAutoresizingMaskIntoConstraints = false
        encryptedString.text = self.encryptedCustomerInput
        encryptedString.isEditable = false
        encryptedString.backgroundColor = .lightGray
        encryptedString.textColor = .darkText
        encryptedString.layer.cornerRadius = 5.0
        container.addSubview(encryptedString)

        let button = Button()
        container.addSubview(button)
        let continueButtonTitle =
            NSLocalizedString(
                "ContinueButtonText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        button.setTitle(continueButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(EndViewController.continueButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let viewMapping: [String: Any] = [
            "label": label,
            "textView": textView,
            "encryptedTextView": encryptedString,
            "button": button
        ]

        var constraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[label]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        container.addConstraints(constraints)
        constraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[textView]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        container.addConstraints(constraints)
        constraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[encryptedTextView]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        container.addConstraints(constraints)
        constraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[button]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        container.addConstraints(constraints)
        constraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[label]-(20)-[textView(110)]-(10)-[encryptedTextView(280)]-(20)-[button]",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        container.addConstraints(constraints)
    }

    @objc func continueButtonTapped() {
        target.didSelectContinueShopping()
    }
}
