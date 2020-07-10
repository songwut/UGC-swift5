//
//  Story.swift
//  Como
//
//  Created by Songwut Maneefun on 6/13/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class Story: NSObject {
    var storyId: Int
    var image: String
    var title: String
    var isSelected: Bool
    var typeDisplay: String
    
    init(storyId: Int, image: String, title: String, isSelected: Bool, typeDisplay: String) {
        self.storyId = storyId
        self.title = title
        self.image = image
        self.isSelected = isSelected
        self.typeDisplay = typeDisplay
        super.init()
    }
}
