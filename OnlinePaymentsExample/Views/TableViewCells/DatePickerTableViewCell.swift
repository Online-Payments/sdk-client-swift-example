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

protocol DatePickerTableViewCellDelegate: AnyObject {
    func datePicker(_ datePicker: UIDatePicker, selectedNewDate date: Date)
}

class DatePickerTableViewCell: TableViewCell {
    class var pickerHeight: CGFloat { return 216 }
    override class var reuseIdentifier: String {
        return "date-picker-cell"
    }

    weak var delegate: DatePickerTableViewCellDelegate?
    let datePicker: UIDatePicker = UIDatePicker()

    var date: Date {
        didSet {
            datePicker.date = date
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        date = Date()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(didPickNewDate(_:)), for: .valueChanged)
        datePicker.date = date
        addSubview(datePicker)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didPickNewDate(_ sender: UIDatePicker) {
        delegate?.datePicker(sender, selectedNewDate: sender.date)
    }

    var readonly: Bool {
        get {
            return !self.datePicker.isEnabled
        }
        set {
            self.datePicker.isEnabled = !newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = contentView.frame.width
        var frame = CGRect(x: 10, y: 0, width: width - 20, height: DatePickerTableViewCell.pickerHeight)
        frame.size = datePicker.sizeThatFits(frame.size)
        frame.origin.x = width/2 - frame.width/2
        datePicker.frame = frame
    }

    override func prepareForReuse() {
        delegate = nil
    }
}
