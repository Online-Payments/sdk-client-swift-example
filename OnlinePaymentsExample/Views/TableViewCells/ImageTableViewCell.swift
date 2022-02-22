//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 04/08/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import UIKit

class ImageTableViewCell: TableViewCell {
    
    var displayImageView = UIImageView()
    
    override class var reuseIdentifier: String { return "image-cell" }
    
    var displayImage: UIImage? {
        get {
            return displayImageView.image
        }
        set {
            displayImageView.image = newValue
        }
    }
    
    static internal func size(transformedFrom size: CGSize, targetWidth: CGFloat) -> CGSize {
        let oldWidth: CGFloat = size.width;
        guard oldWidth != 0 else {
            return CGSize(width: 0, height:0)
        }
        let scaleFactor = targetWidth / oldWidth;
        return CGSize(width: targetWidth, height:size.height * scaleFactor)

    }
    
    static internal func size(transformedFrom size: CGSize, targetHeight: CGFloat) -> CGSize {
        let oldHeight: CGFloat = size.height;
        guard oldHeight != 0 else {
            return CGSize(width: 0, height:0)
        }
        let scaleFactor = targetHeight / oldHeight;
        return CGSize(width: size.width * scaleFactor, height:targetHeight)
        
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(displayImageView)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        let newHeight = ImageTableViewCell.size(transformedFrom: (displayImage?.size)!, targetWidth: width).height
        displayImageView.frame = CGRect(x: leftMargin, y: 0, width:width , height: newHeight)
    }
    
    override func prepareForReuse() {
        displayImage = nil
    }
    
    static func cellSize(width: CGFloat, for row: FormRowImage) -> CGSize {
        return size(transformedFrom: (row.image.size), targetWidth: width)
    }
}
