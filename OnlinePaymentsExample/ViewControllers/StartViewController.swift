//
//  StartViewController.swift
//  OnlinePaymentsExample
//
//  Created for Online Payments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import PassKit
import UIKit
import SVProgressHUD
import OnlinePaymentsKit

// Enable subscripting userdefaults
extension UserDefaults {
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

class StartViewController: UIViewController, ContinueShoppingTarget, PaymentFinishedTarget {

    var containerView: UIView!
    var scrollView: UIScrollView!

    var explanation: UITextView!
    var clientSessionIdLabel: Label!
    var clientSessionIdTextField: TextField!
    var baseURLLabel: Label!
    var baseURLTextField: TextField!
    var assetsBaseURLLabel: Label!
    var assetsBaseURLTextField: TextField!

    var customerIdLabel: Label!
    var customerIdTextField: TextField!
    var merchantIdLabel: Label!
    var merchantIdTextField: TextField!
    var amountLabel: Label!
    var amountTextField: TextField!
    var countryCodeLabel: Label!
    var countryCodeTextField: TextField!
    var currencyCodeLabel: Label!
    var currencyCodeTextField: TextField!
    var isRecurringLabel: Label!
    var isRecurringSwitch: Switch!
    var payButton: UIButton!
    var pasteButton: UIButton!
    var pasteErrorLabel: UILabel!

    var paymentProductsViewControllerTarget: PaymentProductsViewControllerTarget?

    var amountValue: Int = 0

    var sdk: OnlinePaymentsSdk?
    var context: PaymentContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTapRecognizer()

        if responds(to: #selector(getter: edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delaysContentTouches = false
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(scrollView)

        let superContainerView = UIView()
        superContainerView.translatesAutoresizingMaskIntoConstraints = false
        superContainerView.autoresizingMask = .flexibleWidth
        scrollView.addSubview(superContainerView)

        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        superContainerView.addSubview(containerView!)

        explanation = UITextView()
        explanation.translatesAutoresizingMaskIntoConstraints = false
        explanation.text =
            NSLocalizedString(
                "SetupExplanationText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        explanation.isEditable = false
        explanation.backgroundColor =
            UIColor(red: CGFloat(0.85), green: CGFloat(0.94), blue: CGFloat(0.97), alpha: CGFloat(1))
        explanation.textColor = UIColor(red: CGFloat(0), green: CGFloat(0.58), blue: CGFloat(0.82), alpha: CGFloat(1))
        explanation.layer.cornerRadius = 5.0
        explanation.isScrollEnabled = false
        containerView.addSubview(explanation)

        clientSessionIdLabel = Label()
        clientSessionIdLabel.text =
            NSLocalizedString(
                "ClientSessionIdentifierTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Client session identifier"
            )
        clientSessionIdLabel.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField = TextField()
        clientSessionIdTextField.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kClientSessionId) as? String {
            clientSessionIdTextField.text = text
        } else {
            clientSessionIdTextField.text = ""
        }

        containerView.addSubview(clientSessionIdLabel)
        containerView.addSubview(clientSessionIdTextField)

        customerIdLabel = Label()
        customerIdLabel.text =
            NSLocalizedString(
                "CustomerIdentifierTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Customer identifier"
            )
        customerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField = TextField()
        customerIdTextField.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCustomerId) as? String {
            customerIdTextField.text = text
        } else {
            customerIdTextField.text = ""
        }
        containerView.addSubview(customerIdLabel)
        containerView.addSubview(customerIdTextField)

        merchantIdLabel = Label()
        merchantIdLabel.text =
            NSLocalizedString(
                "MerchantIdentifierTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Merchant identifier"
            )
        merchantIdLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField = TextField()
        merchantIdTextField.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kMerchantId) as? String {
            merchantIdTextField.text = text
        } else {
            merchantIdTextField.text = ""
        }
        containerView.addSubview(merchantIdLabel)
        containerView.addSubview(merchantIdTextField)

        baseURLLabel = Label()
        baseURLLabel.text =
            NSLocalizedString(
                "BaseURL",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        baseURLLabel.translatesAutoresizingMaskIntoConstraints = false
        baseURLTextField = TextField()
        baseURLTextField.translatesAutoresizingMaskIntoConstraints = false
        baseURLTextField.autocapitalizationType = .none
        baseURLTextField.autocorrectionType = .no
        baseURLTextField.keyboardType = .URL
        if let text = UserDefaults.standard.value(forKey: AppConstants.kBaseURL) as? String {
            baseURLTextField.text = text
        } else {
            baseURLTextField.text = ""
        }
        containerView.addSubview(baseURLLabel)
        containerView.addSubview(baseURLTextField)

        assetsBaseURLLabel = Label()
        assetsBaseURLLabel.text =
            NSLocalizedString(
                "AssetsBaseURL",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        assetsBaseURLLabel.translatesAutoresizingMaskIntoConstraints = false
        assetsBaseURLTextField = TextField()
        assetsBaseURLTextField.translatesAutoresizingMaskIntoConstraints = false
        assetsBaseURLTextField.autocapitalizationType = .none
        assetsBaseURLTextField.autocorrectionType = .no
        assetsBaseURLTextField.keyboardType = .URL
        if let text = UserDefaults.standard.value(forKey: AppConstants.kAssetsBaseURL) as? String {
            assetsBaseURLTextField.text = text
        } else {
            assetsBaseURLTextField.text = ""
        }
        containerView.addSubview(assetsBaseURLLabel)
        containerView.addSubview(assetsBaseURLTextField)

        pasteButton = Button(type: .secondary)
        pasteButton.setTitle(
            NSLocalizedString(
                "PasteButtonText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Paste from clipboard"
            ),
            for: .normal
        )

        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        //pasteButton.backgroundColor = .systemBlue
        pasteButton.addTarget(self, action: #selector(StartViewController.pasteButtonTapped), for: .touchUpInside)
        containerView.addSubview(pasteButton)

        pasteErrorLabel = UILabel()
        pasteErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        pasteErrorLabel.textColor = .red
        pasteErrorLabel.numberOfLines = 0
        pasteErrorLabel.isHidden = true

        containerView.addSubview(pasteErrorLabel)

        amountLabel = Label()
        amountLabel.text =
            NSLocalizedString(
                "AmountInCentsTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Amount in cents"
            )
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField = TextField()
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        if let amount = UserDefaults.standard.value(forKey: AppConstants.kPrice) as? Int {
            amountTextField.text = String(amount)
        } else {
            amountTextField.text = "100"
        }
        containerView.addSubview(amountLabel)
        containerView.addSubview(amountTextField)

        countryCodeLabel = Label()
        countryCodeLabel.text =
            NSLocalizedString(
                "CountryCodeTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Country code"
            )
        countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false

        countryCodeTextField = TextField()
        countryCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        countryCodeTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCountryCode) as? String {
            countryCodeTextField.text = text
        } else {
            countryCodeTextField.text = ""
        }
        containerView.addSubview(countryCodeLabel)
        containerView.addSubview(countryCodeTextField)

        currencyCodeLabel = Label()
        currencyCodeLabel.text =
            NSLocalizedString(
                "CurrencyCodeTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Currency code"
            )
        currencyCodeLabel.translatesAutoresizingMaskIntoConstraints = false

        currencyCodeTextField = TextField()
        currencyCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        currencyCodeTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCurrency) as? String {
            currencyCodeTextField.text = text
        } else {
            currencyCodeTextField.text = ""
        }
        containerView.addSubview(currencyCodeLabel)
        containerView.addSubview(currencyCodeTextField)

        isRecurringLabel = Label()
        isRecurringLabel.text =
            NSLocalizedString(
                "RecurringPaymentTitle",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Payment is recurring"
            )
        isRecurringLabel.translatesAutoresizingMaskIntoConstraints = false
        isRecurringSwitch = Switch()
        isRecurringSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(isRecurringLabel)
        containerView.addSubview(isRecurringSwitch)

        payButton = Button()
        payButton.setTitle(
            NSLocalizedString(
                "StartPaymentProcessButtonText",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Pay securely now"
            ),
            for: .normal
        )
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(StartViewController.buyButtonTapped), for: .touchUpInside)
        containerView.addSubview(payButton)

        let views: [String: AnyObject] = [
            "explanation": explanation,
            "clientSessionIdLabel": clientSessionIdLabel,
            "clientSessionIdTextField": clientSessionIdTextField,
            "customerIdLabel": customerIdLabel,
            "customerIdTextField": customerIdTextField,
            "merchantIdLabel": merchantIdLabel,
            "merchantIdTextField": merchantIdTextField,
            "baseURLLabel": baseURLLabel,
            "baseURLTextField": baseURLTextField,
            "assetsBaseURLLabel": assetsBaseURLLabel,
            "assetsBaseURLTextField": assetsBaseURLTextField,
            "pasteButton": pasteButton,
            "pasteErrorLabel": pasteErrorLabel,
            "amountLabel": amountLabel,
            "amountTextField": amountTextField,
            "countryCodeLabel": countryCodeLabel,
            "countryCodeTextField": countryCodeTextField,
            "currencyCodeLabel": currencyCodeLabel,
            "currencyCodeTextField": currencyCodeTextField,
            "isRecurringLabel": isRecurringLabel,
            "isRecurringSwitch": isRecurringSwitch,
            "payButton": payButton,
            "superContainerView": superContainerView,
            "containerView": containerView,
            "scrollView": scrollView
        ]
        let metrics = ["fieldSeparator": "24", "groupSeparator": "72"]

        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[explanation]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[clientSessionIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[clientSessionIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[customerIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[customerIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[baseURLLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[baseURLTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[assetsBaseURLLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[assetsBaseURLTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "[pasteButton]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[pasteErrorLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[amountLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[amountTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[countryCodeLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[countryCodeTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[currencyCodeLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[currencyCodeTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[isRecurringLabel]-[isRecurringSwitch]-|",
                options: [.alignAllCenterY],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "|-[payButton]-|", options: [], metrics: nil, views: views)
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat:
                    // swiftlint:disable line_length
                    "V:|-(fieldSeparator)-[explanation]-(fieldSeparator)-[clientSessionIdLabel]-[clientSessionIdTextField]-(fieldSeparator)-[customerIdLabel]-[customerIdTextField]-(fieldSeparator)-[baseURLLabel]-[baseURLTextField]-(fieldSeparator)-[assetsBaseURLLabel]-[assetsBaseURLTextField]-(fieldSeparator)-[merchantIdLabel]-[merchantIdTextField]-(fieldSeparator)-[pasteButton]-[pasteErrorLabel]-(groupSeparator)-[amountLabel]-[amountTextField]-(fieldSeparator)-[countryCodeLabel]-[countryCodeTextField]-(fieldSeparator)-[currencyCodeLabel]-[currencyCodeTextField]-(fieldSeparator)-[isRecurringSwitch]-(fieldSeparator)-[payButton]-|",
                    // swiftlint:enable line_length
                options: [],
                metrics: metrics,
                views: views
            )
        )
        self.view.addConstraints(
            [
                NSLayoutConstraint(
                    item: superContainerView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: self.view,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: superContainerView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: self.view,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0
                )
            ]
        )

        self.scrollView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[superContainerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.scrollView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[superContainerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[scrollView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[scrollView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )

        superContainerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[containerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        superContainerView.addConstraint(
            NSLayoutConstraint(
                item: self.containerView!,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 320
            )
        )
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.containerView!,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )

    }

    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScrollView)
    }

    @objc func tableViewTapped() {
        for view: UIView in containerView!.subviews {
            if let textField = view as? TextField, textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }

    // MARK: - Button actions

    @objc func pasteButtonTapped(_ sender: UIButton) {
        pasteErrorLabel.isHidden = true
        pasteErrorLabel.text = ""

        guard let pasteboardString = UIPasteboard.general.string
        else {
            showPasteError("No string found on pasteboard.")
            return
        }

        guard let data = pasteboardString.data(using: .utf8)
        else {
            showPasteError("Could not convert clipboard string to UTF-8 data.")
            return
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let clientSessionId = jsonObject["clientSessionId"] as? String {
                    clientSessionIdTextField.text = clientSessionId
                }

                if let baseURL = jsonObject["clientApiUrl"] as? String {
                    baseURLTextField.text = baseURL
                }

                if let assetsBaseURL = jsonObject["assetUrl"] as? String {
                    assetsBaseURLTextField.text = assetsBaseURL
                }

                if let customerId = jsonObject["customerId"] as? String {
                    customerIdTextField.text = customerId
                }
            } else {
                showPasteError("JSON was not in the expected [String: Any] format.")
            }
        } catch {
            showPasteError("Clipboard does not contain a valid JSON string.")
        }
    }


    @objc func buyButtonTapped(_ sender: UIButton) {
        if payButton == sender, let newValue = Int(amountTextField.text!) {
            amountValue = newValue
            UserDefaults.standard.set(newValue, forKey: AppConstants.kPrice)
        } else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid sender"),
                reason: "Sender is invalid", userInfo: nil
            ).raise()
        }

        SVProgressHUD.setDefaultMaskType(.clear)
        let status =
            NSLocalizedString(
                "LoadingMessage",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: ""
            )
        SVProgressHUD.show(withStatus: status)

        guard let clientSessionId = clientSessionIdTextField.text,
              let customerId = customerIdTextField.text
        else {
            let alert =
                UIAlertController(
                    title:
                        NSLocalizedString(
                            "FieldErrorTitle",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    message:
                        NSLocalizedString(
                            "FieldErrorClientSessionIdCustomerIdExplanation",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    preferredStyle: .alert
                )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        UserDefaults.standard[AppConstants.kClientSessionId] = clientSessionId
        UserDefaults.standard[AppConstants.kCustomerId] = customerId
        if let merchantId = merchantIdTextField.text {
            UserDefaults.standard.set(merchantId, forKey: AppConstants.kMerchantId)
        }
        let baseURL = baseURLTextField.text
        UserDefaults.standard[AppConstants.kBaseURL] = baseURL

        let assetBaseURL = assetsBaseURLTextField.text
        UserDefaults.standard[AppConstants.kAssetsBaseURL] = assetBaseURL

        // ***************************************************************************
        //
        // The Online Payments SDK supports processing payments with instances of the
        // Session class. The code below shows how such an instance chould be
        // instantiated.
        //
        // The Session class uses a number of supporting objects. There is an
        // initializer for this class that takes these supporting objects as
        // arguments. This should make it easy to replace these additional objects
        // without changing the implementation of the SDK. Use this initializer
        // instead of the factory method used below if you want to replace any of the
        // supporting objects.
        //
        // You can log requests made to the server and responses received from the server
        // by passing the `loggingEnabled` parameter to the Session constructor.
        // In the constructor below, the logging is disabled.
        // You are also able to disable / enable logging at a later stage
        // by calling `session.loggingEnabled = `, as shown below.
        // Logging should be disabled in production.
        // To use logging in debug, but not in production, you can set `loggingEnabled` within a DEBUG flag.
        // If you use the DEBUG flag, you can take a look at this app's build settings
        // to see the setup you should apply to your own app.
        // ***************************************************************************

        do {
            let sessionData = SessionData(
                clientSessionId: clientSessionId,
                customerId: customerId,
                clientApiUrl: baseURL ?? "",
                assetUrl: assetBaseURL ?? ""
            )
            
            sdk = try OnlinePaymentsSdk(sessionData: sessionData)
        } catch {
            SVProgressHUD.dismiss()
            self.showPaymentProductsErrorDialog()
            
            return
        }

        guard let countryCode = countryCodeTextField.text,
              let currencyCode = currencyCodeTextField.text
        else {
            let alert =
                UIAlertController(
                    title:
                        NSLocalizedString(
                            "FieldErrorTitle",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    message:
                        NSLocalizedString(
                            "FieldErrorCountryCodeCurrencyExplanation",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    preferredStyle: .alert
                )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }

        UserDefaults.standard[AppConstants.kCountryCode] = countryCode
        UserDefaults.standard[AppConstants.kCurrency] = currencyCode
        let isRecurring = isRecurringSwitch.isOn

        // ***************************************************************************
        //
        // To retrieve the available payment products, the information stored in the
        // following PaymentContext object is needed.
        //
        // After the Session object has retrieved the payment products that match
        // the information stored in the PaymentContext object, a
        // selection screen is shown. This screen itself is not part of the SDK and
        // only illustrates a possible payment product selection screen.
        //
        // ***************************************************************************
        let amountOfMoney = AmountOfMoney(amount: amountValue, currencyCode: currencyCode)
        context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: isRecurring, countryCode: countryCode)

        guard let context = context
        else {
            Macros.DLog(message: "Could not find context")
            let alert =
                UIAlertController(
                    title:
                        NSLocalizedString(
                            "ConnectionErrorTitle",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    message:
                        NSLocalizedString(
                            "PaymentProductsErrorExplanation",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    preferredStyle: .alert
                )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            SVProgressHUD.dismiss()

            return
        }

        guard let sdk = sdk else {
            SVProgressHUD.dismiss()
            showPaymentProductsErrorDialog()
            
            return
        }
        
        sdk.basicPaymentProducts(
            forContext: context,
            success: { (basicPaymentProducts: BasicPaymentProducts) -> Void in
                SVProgressHUD.dismiss()
                self.showPaymentProductSelection(basicPaymentProducts)
            },
            failure: { _ in
                self.showPaymentProductsErrorDialog()
            }
        )
    }

    private func showPaymentProductsErrorDialog() {
        SVProgressHUD.dismiss()
        let alert =
            UIAlertController(
                title:
                    NSLocalizedString(
                        "ConnectionErrorTitle",
                        tableName: AppConstants.kAppLocalizable,
                        bundle: AppConstants.appBundle,
                        value: "",
                        comment: ""
                    ),
                message:
                    NSLocalizedString(
                        "PaymentProductsErrorExplanation",
                        tableName: AppConstants.kAppLocalizable,
                        bundle: AppConstants.appBundle,
                        value: "",
                        comment: ""
                    ),
                preferredStyle: .alert
            )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showPaymentProductSelection(_ basicPaymentProducts: BasicPaymentProducts) {
        guard let context = context, let navigationController = navigationController else {
            return
        }
        
        paymentProductsViewControllerTarget =
            PaymentProductsViewControllerTarget(
                navigationController: navigationController,
                sdk: sdk,
                context: context
            )
                        
        let paymentProductSelection = PaymentProductsViewController(
            style: .grouped,
            basicPaymentProducts: basicPaymentProducts
        )
        
        paymentProductSelection.target = paymentProductsViewControllerTarget
        paymentProductSelection.amount = amountValue
        paymentProductSelection.currencyCode = context.amountOfMoney.currencyCode
        navigationController.pushViewController(paymentProductSelection, animated: true)
        SVProgressHUD.dismiss()
    }

    // MARK: - Continue shopping target

    func didSelectContinueShopping() {
        navigationController!.popToRootViewController(animated: true)
    }

    // MARK: - Payment finished target

    func didFinishPayment(_ encryptedCustomerInput: String) {
        let end = EndViewController(encryptedCustomerInput: encryptedCustomerInput)
        end.target = self
        navigationController!.pushViewController(end, animated: true)
    }

    private func showPasteError(_ message: String) {
        pasteErrorLabel.text = message
        pasteErrorLabel.isHidden = false
    }
}

extension StartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Picker view delegate

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let picker = pickerView as? PickerView
        else {
            fatalError("Could not cast picker to PickerView")
        }

        return picker.content.count
    }

    public func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        guard let picker = pickerView as? PickerView
        else {
            fatalError("Could not cast picker to PickerView")
        }

        let item = picker.content[row]
        return NSAttributedString(string: item)
    }
}
