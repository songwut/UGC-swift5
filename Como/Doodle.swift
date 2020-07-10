//
//  Doodle.swift
//  Como
//
//  Created by Songwut Maneefun on 6/20/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation
import UIKit

class Doodle {
    var id: Int!
    var type: Int!
    var imageStr: String!
    var name: String!
    var typeDisplay: String!
    var isFullScreen: Bool!
    var isSelected: Bool!
    
    var image: UIImage?
    
    init(id: Int, type: Int, imageStr: String, name: String, typeDisplay: String, isFullScreen: Bool, isSelected: Bool) {
        self.id = id
        self.type = type
        self.imageStr = imageStr
        self.name = name
        self.typeDisplay = typeDisplay
        self.isFullScreen = isFullScreen
        self.isSelected = isSelected
    }
}