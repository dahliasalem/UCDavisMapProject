
import Foundation
import RealmSwift

class Helpers {
    
    static let realm = try! Realm()
    
    
    
    static func DB_insert(obj : Object){
    
    try! self.realm.write{
    
        self.realm.add(obj)
    
    
    }
        /*
        func printSome () {
            
            
            debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)

            
        }*/
    
    }
    
    //print("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)
    
    

    
    
}
