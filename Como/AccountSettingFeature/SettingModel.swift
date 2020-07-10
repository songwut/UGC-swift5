//
//  SettingModel.swift
//  Como
//
//  Created by Songwut Maneefun on 6/2/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class SettingModel: NSObject {

    var title: String
    var detail: String
    var tag: Int
    
    init(_ title: String, _ detail: String, _ tag: Int) {
        self.title = title
        self.detail = detail
        self.tag = tag
        super.init()
    }
}
