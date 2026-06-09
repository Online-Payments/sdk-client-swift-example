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

class MerchantLogoImageView: UIImageView {

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let logo = UIImage(named: "MerchantLogo")
        contentMode = .scaleAspectFit
        image = logo
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
