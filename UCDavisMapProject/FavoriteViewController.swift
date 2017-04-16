

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDataSource {


    var favLocations = [Location]()
    @IBOutlet weak var favTable: UITableView!
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadTableData()
        
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTableData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    func reloadTableData() {
        favLocations = Array(try! Realm().objects(Location.self).filter("isFavorite == true").sorted(byKeyPath: "name" , ascending: true ))
        self.favTable.reloadData()
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
        return favLocations.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as UITableViewCell
             cell.textLabel?.text = favLocations[indexPath.row].name
        
        
        return cell
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addFav" {
            
            
            let destViewController = segue.destination as! UINavigationController
            let searchViewController = destViewController.topViewController as! SearchViewController
            searchViewController.isComingFromFavorites = true
            
     
        }
        
        
        if segue.identifier == "showFav" {
            if let indexPath = self.favTable.indexPathForSelectedRow {
                 let  loce = favLocations[indexPath.row]
                 (segue.destination as! LocationDetailViewController).detailLocation = loce
            }
            
        }
        
    }
    
    
}
