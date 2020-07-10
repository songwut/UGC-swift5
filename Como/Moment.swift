//
//  Moment.swift
//  Como
//
//  Created by Songwut Maneefun on 6/21/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol Mappable {
    init?(_ map: Map)
    mutating func mapping(map: Map)
    //static func objectForMapping(map: Map) -> Mappable? // Optional
}

class Moment {
    var id: Int
    var views: Int
    var likes: Int
    var type: Int
    var latitude: Double
    var longitude: Double
    var timestamp: String
    var typeDisplay: String
    var isLiked: Bool
    var duration: Int
    var path: String
    var userName: String
    var userImage: String
    
    init(id: Int, views: Int, likes: Int, type: Int, latitude: Double, longitude: Double, timestamp: String, typeDisplay: String, isLiked: Bool, duration: Int, path: String, userName: String, userImage: String) {
        self.id = id
        self.views = views
        self.likes = likes
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.typeDisplay = typeDisplay
        self.isLiked = isLiked
        self.duration = duration
        self.path = path
        self.userName = userName
        self.userImage = userImage
    }
}


func checkString(strObj: AnyObject) -> String {
    if (strObj as! String).isEmpty { return "" }
    return "\(strObj)"
}

func checkInt(intObj: AnyObject) -> Int {
    if let i = Int(intObj as! String) {
        return i
    } else {
        return 0
    }
}

func checkDouble(doubleObj: AnyObject) -> Double {
    if let d = Double(doubleObj as! String) {
        return d
    } else {
        return 0.0
    }
}