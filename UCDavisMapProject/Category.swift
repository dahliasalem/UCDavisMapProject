

import Foundation
import RealmSwift

class Category: Object {
    
    var locations = List<Location>()
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }

}
