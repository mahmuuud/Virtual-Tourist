//
//  SearchPhotoResponse.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/12/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import Foundation

struct Photo:Codable {
    var id:String
    var owner:String
    var secret:String
    var server:String
    var farm:Int
    var title:String
    var isPublic:Int
    var isFriend:Int
    var isFamily:Int
    
    private enum CodingKeys:String,CodingKey{
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic="ispublic"
        case isFriend="isfriend"
        case isFamily="isfamily"
    }
}
