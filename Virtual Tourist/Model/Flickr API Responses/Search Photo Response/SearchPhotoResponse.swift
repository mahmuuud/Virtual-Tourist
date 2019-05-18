//
//  SearchPhotoResponse.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/12/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import Foundation

struct SearchPhotoResponse:Codable {
    var photos:PhotosDetails
    var stat:String
}
