//
//  Client.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/10/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import Foundation
import UIKit

class Client{
    static let apiKey="5bf57f17a2d5833590f62b7cdb4abe27"
    static let secret="28c48e0fd708fcac"
    
    enum EndPoints{
        case photosSearch(lat:Double,lon:Double)
        case getImage(farm:Int,server:String,id:String,secret:String)
        
        var stringValue:String{
            switch self {
            case .photosSearch(let lat,let lon):
                return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Client.apiKey)&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1"
            case .getImage(let farm,let server,let id, let secret):
                return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
            }
            
        }
        
        var url:URL{
            return URL(string: stringValue)!
        }
    }
    
    class func searchPhoto(lat:Double,lon:Double,completionHandler:@escaping([Photo]?,Error?)->Void){
        let url=EndPoints.photosSearch(lat: lat, lon: lon).url
        let task=URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || data==nil{
                completionHandler(nil,error)
                return
            }
            
            do{
                let response=try JSONDecoder().decode(SearchPhotoResponse.self, from: data!)
                completionHandler(response.photos.photo,nil)
            }
            
            catch{
                print(error)
                completionHandler(nil,error)
            }
            
        }
        task.resume()
    }
    
    class func getImages(photos:[Photo],completionHandler:@escaping([UIImage]?,Error?)->Void){
        var images:[UIImage] = []
        let dispatchGroup = DispatchGroup()
        var count = 20
        if photos.count < 20 {
            count = photos.count-1
        }
        if count > 0 {
            for i in 0...count{
                let url = EndPoints.getImage(farm: photos[i].farm, server: photos[i].server, id: photos[i].id, secret: photos[i].secret).url
                dispatchGroup.enter()
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if error != nil || data == nil{
                        completionHandler(nil,error)
                        return
                    }
                    images.append(UIImage(data: data!)!)
                    dispatchGroup.leave()
                })
                task.resume()
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completionHandler(images,nil)
                print(images.count)
            }
        }
        else{
            completionHandler(nil,nil)
        }
        
    }
  
}
