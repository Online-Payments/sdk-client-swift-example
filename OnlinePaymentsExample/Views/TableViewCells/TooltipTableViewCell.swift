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

class TooltipTableViewCell: TableViewCell {
    private var tooltipLabel = UILabel()
    private var tooltipImageContainer = UIImageView()

    override class var reuseIdentifier: String { return "info-cell" }

    var label: String? {
        get {
            return tooltipLabel.text
        }
        set {
            tooltipLabel.text = newValue
        }
    }

    var tooltipImage: UIImage? {
        get {
            return tooltipImageContainer.image
        }
        set {
            tooltipImageContainer.image = newValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        tooltipImageContainer.contentMode = .scaleAspectFit
        tooltipLabel.font = UIFont.systemFont(ofSize: 10.0)
        tooltipLabel.numberOfLines = 0
        clipsToBounds = true

        contentView.addSubview(tooltipImageContainer)
        contentView.addSubview(tooltipLabel)
    }

    private class func labelSize(width: CGFloat, text: String) -> CGSize {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let text = text as NSString
        let rect =
            text.boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin),
                attributes: [:],
                context: nil
            )
        return rect.size
    }

    class func cellSize(width: CGFloat, formRow: FormRowTooltip) -> CGSize {
        var rect = TooltipTableViewCell.labelSize(width: width, text: formRow.text ?? "")
        rect.height += 8
        return rect
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        tooltipLabel.frame = CGRect(x: Int(leftMargin), y: 4, width: Int(width - 30), height: Int.max)
        tooltipLabel.sizeToFit()
        if let image = tooltipImage {
            let ratio = image.size.width / image.size.height
            if !ratio.isNaN {
                tooltipImageContainer.frame = CGRect(x: leftMargin, y: 40, width: 100 * ratio, height: 100)
                return
            }
            tooltipImageContainer.frame = CGRect(x: leftMargin, y: 40, width: 0, height: 0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        label = nil
        tooltipImage = nil
    }
}
