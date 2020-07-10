//
//  NotifyUploadInfo.swift
//  Como
//
//  Created by Songwut Maneefun on 6/13/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class NotifyUploadInfo: NSObject {
    var progress: Float!
    var isFail: Bool!
    
    init(progress: Float, isFail: Bool) {
        self.progress = progress
        self.isFail = isFail
        super.init()
    }
}
