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

class DetailedPickerViewTableViewCell: PickerViewTableViewCell, UIPickerViewDelegate {
    var labelView = UITextView()
    override class var reuseIdentifier: String {
        return "detailed-picker-view-cell"
    }
    var transitiveDelegate: UIPickerViewDelegate?
    var currencyFormatter: NumberFormatter!
    var percentFormatter: NumberFormatter!
    var fieldIdentifier: String!
    let errorLabel = Label()
    private var labelNeedsUpdate = true

    override var delegate: UIPickerViewDelegate? {
        get {
            return transitiveDelegate
        }
        set {
            transitiveDelegate = newValue
        }
    }

    override var selectedRow: Int? {
        get {
            return pickerView.selectedRow(inComponent: 0)
        }
        set {
            pickerView.selectRow(newValue ?? 0, inComponent: 0, animated: false)
            if labelNeedsUpdate {
                self.updateLabel(row: newValue ?? 0)
            }

        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(pickerView)
        addSubview(labelView)
        addSubview(errorLabel)

        pickerView.delegate = self
        labelView.isEditable = false
        labelView.isScrollEnabled = false
        labelView.dataDetectorTypes = UIDataDetectorTypes.link

        errorLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .red

        self.clipsToBounds = true
        self.setNeedsLayout()
        contentView.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        return delegate?.pickerView!(_: pickerView, attributedTitleForRow: row, forComponent: component)
    }

    func updateLabel(row: Int) {
        self.labelNeedsUpdate = false

        self.labelView.attributedText = label(row: row)
        labelView.sizeToFit()

    }

    func label(row: Int) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops =
            [
                NSTextTab(
                    textAlignment: NSTextAlignment.right,
                    location: self.accessoryAndMarginCompatibleWidth() - 10,
                    options: [:]
                )
            ]

        return NSAttributedString()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateLabel(row: row)
        delegate?.pickerView!(_: pickerView, didSelectRow: row, inComponent: component)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = self.accessoryCompatibleLeftMargin()

        errorLabel.frame =
            CGRect(x: leftMargin, y: DetailedPickerViewTableViewCell.pickerHeight + 5, width: width, height: 500)
        errorLabel.preferredMaxLayoutWidth = width - 20
        errorLabel.sizeToFit()

        var labelFrame =
            CGRect(
                x: leftMargin,
                y: DetailedPickerViewTableViewCell.pickerHeight + 10 + errorLabel.frame.size.height,
                width: width,
                height: DatePickerTableViewCell.pickerHeight
            )
        labelFrame.size.height =
            self.labelView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        self.labelView.frame = labelFrame

        if labelNeedsUpdate {
            updateLabel(row: selectedRow ?? 0)
        }
    }

    override func prepareForReuse() {
        dataSource = nil
        selectedRow = nil
    }
}
