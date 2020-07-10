//
//  Filter.swift
//  Como
//
//  Created by Songwut Maneefun on 6/18/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class Filter: NSObject {
    var name: String
    var ciImageName: String
    var image: UIImage?
    var tag: Int?
    
    init(filterName name: String, ciImageName: String, image: UIImage?, tag: Int?) {
        self.name = name
        self.ciImageName = ciImageName
        self.image = image
        self.tag = tag
        super.init()
    }
}
