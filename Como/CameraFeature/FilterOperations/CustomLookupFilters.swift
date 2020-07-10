//
//  CustomLookupFilters.swift
//  Como
//
//  Created by Songwut Maneefun on 6/17/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation
import GPUImage

class OriginalFiltersdd: LookupFilter {
    
}

class OriginalFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_Original.png")})()
        ({intensity = 1.0})()
    }
}

class CyanGoldFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_CyanGold.png")})()
        ({intensity = 1.0})()
    }
}

class LoverFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_Lover.png")})()
        ({intensity = 1.0})()
    }
}

class RetroASFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_RetroAS.png")})()
        ({intensity = 1.0})()
    }
}

class SepiaGoldFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_SepiaGold.png")})()
        ({intensity = 1.0})()
    }
}

class VictorianFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"filter_Victorian.png")})()
        ({intensity = 1.0})()
    }
}
