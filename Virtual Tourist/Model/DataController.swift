//
//  DataController.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/28/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let persistanceContainer:NSPersistentContainer
    var viewContext:NSManagedObjectContext{
        return persistanceContainer.viewContext
    }
    
    init(modelName:String) {
        persistanceContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion:(()->Void)?=nil){
        self.persistanceContainer.loadPersistentStores { (storeDescription, error) in
            guard  error == nil else{
                print("cannot load store🚨")
                return
            }
            
        }
    }
    
}
