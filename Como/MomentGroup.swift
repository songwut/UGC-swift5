//
//  MomentGroup.swift
//  Como
//
//  Created by Songwut Maneefun on 5/30/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class MomentGroup: NSObject {

    var id: Int
    var day: Int
    var month: String
    
    init(momentID id: Int, day: Int, month: String) {
        self.id = id
        self.day = day
        self.month = month
        super.init()
    }
}
