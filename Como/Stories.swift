//
//  Stories.swift
//  Como
//
//  Created by Songwut Maneefun on 5/26/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation

class GroupSend {
    var group: String?
    var senderList: Array<StorySend>
    init(group: String, senderList: Array<StorySend>) {
        self.group = group
        self.senderList = senderList
    }
}

class StorySend {
    var storyId = 0
    var contentTypeId = 0
    var image: String!
    var title: String!
    var description: String!
    var group: String!
    var isSelected: Bool!
    
    init(storyId: Int, contentTypeId: Int, image: String, title: String, description: String, group: String, isSelected: Bool) {
        self.storyId = storyId
        self.contentTypeId = contentTypeId
        self.title = title
        self.description = description
        self.image = image
        self.isSelected = isSelected
        
    }
}
