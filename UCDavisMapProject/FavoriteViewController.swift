

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDataSource {


    var favLocations = [Location]()
    @IBOutlet weak var favTable: UITableView!
 
    var something = "lol"
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        queryrealm()
        self.favTable.reloadData()
            }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        queryrealm()
        self.favTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    func queryrealm () {
        
        favLocations.removeAll()
        
        let favObjects = try! Realm().objects(Location.self).filter("isFavorite == true")
               for fav in favObjects {
            
            favLocations.append(fav)
        }
 
           }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
        return favLocations.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //queryrealm()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as UITableViewCell
             cell.textLabel?.text = favLocations[indexPath.row].Name
        
        
        return cell
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addFav" {
            
            print("inside if")
            let locya = something
            
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! SearchViewController
            targetController.detailSome = locya
            
     
        }
        
        
        if segue.identifier == "showFav" {
            
            if let indexPath = self.favTable.indexPathForSelectedRow {
                 let  loce = favLocations[indexPath.row]
                 (segue.destination as! LocationDetailViewController).detailLocation = loce
            }

            
        }
        
    }
    
    
}
