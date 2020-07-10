//
//  Sticker.swift
//  Como
//
//  Created by Songwut Maneefun on 6/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class StickerGroup: NSObject {
    var id: Int
    var groupName: String
    var groupList: NSMutableArray
    
    init(groupId id: Int, groupName: String, groupList: NSMutableArray) {
        self.id = id
        self.groupName = groupName
        self.groupList = groupList
        super.init()
    }
}

class Sticker: NSObject {
    var id: Int
    var image: String
    
    init(stickerId id: Int, image: String) {
        self.id = id
        self.image = image
        super.init()
    }
}
