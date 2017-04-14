

import Foundation
import RealmSwift

class Category: Object {
    
    var locations = List<Location>()
    //locations.
    dynamic var name = "null"
    dynamic var id = Location().Name
    //var lf = locations
    
    
    //dynamic lazy var compoundKey: String = Location.Nam

    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    
}
