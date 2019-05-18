//
//  PhotosDetails.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/12/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import Foundation
struct PhotosDetails:Codable {
    var page:Int
    var pages:Int
    var perPage:Int
    var total:String
    var photo:[Photo]
    
    private enum CodingKeys:String, CodingKey{
        case page
        case pages
        case perPage="perpage"
        case total
        case photo
    }
}
