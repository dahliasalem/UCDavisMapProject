

import Foundation
import RealmSwift

class Location : Object {
    
    
    dynamic var name = ""
    dynamic var link = ""
    dynamic var lat: Double = 0.0
    dynamic var lng: Double = 0.0
    dynamic var isFavorite = false

    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}

    
    

