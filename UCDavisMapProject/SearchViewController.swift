

import UIKit
import Foundation
import RealmSwift


class SearchViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    var Locations = [Location]()
    let realm:Realm = try! Realm()
    var reach = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // var NSURLSession : NSURLSession
        
        if reach.isInternetAvailable() == true {
            
            //print("yes")
            try! realm.write {
                realm.deleteAll()
            }
            parseJSON()
            
        } else {
            
            queryLoc()
            
        }
        
        
    }
    
    
    func parseJSON () {
        
        //Helpers.printSome()
        debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString)
        let requestURL: NSURL = NSURL(string: "http://mobile.ucdavis.edu/locations/?format=json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            
            
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                
                do{
                    
                    var names = [String]()
                    
                    // var categories = [Category]()
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [[String:AnyObject]]
                    
                    for i in 0...json.count-1 {
                        
                        
                        let category = Category()
                        category.name = json[i]["name"] as! String
                        
                        
                        if let stations = json[i]["locations"] as? [[String: AnyObject]] {
                            
                            for station in stations {
                                
                                if let name = station["name"] as? String {
                                    
                                    if let link = station["link"] as? String {
                                        
                                        if let lat = station["lat"] as? String{
                                            
                                            if let lng = station["lng"] as? String {
                                                let location = Location()
                                                
                                                
                                                location.Name = name
                                                location.Link = link
                                                location.lat = lat
                                                location.lng = lng
                                                
                                                category.locations.append(location)
                                                //print(name)
                                                
                                            }
                                        }
                                    }
                                    names.append(name)
                                    //print(name)
                                }
                            }
                        }
                        
                        Helpers.DB_insert(obj: category)
                        
                    }
                    
                    
                    
                    
                    DispatchQueue.main.async{
                        self.queryLoc ()
                        self.tableView.reloadData()
                    }
                    
                    
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
                
            }
        }
        
        task.resume()
        
        
        
        
    }
    
    
    
    
    func queryLoc () {
        
        
        //let CatObjects = try! Realm().objects(Category.self)
        let LocObjects = try! Realm().objects(Location.self)
        
        
        let byName = LocObjects.sorted(byKeyPath: "Name" , ascending: true )
        
        for loc in byName {
            
            Locations.append(loc)
            
            //print("\(loc.Name) is something")
            
            
            //tableView.reloadData()
        }
        
        
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Locations.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as UITableViewCell
        
        
        var locya: Location
        
        locya = Locations[indexPath.row]
        
        cell.textLabel?.text = locya.Name
        
        
        return cell
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.tabBarItem.title = "title"
        //self.tabBarItem.image = "image.png"
    }
    
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     if segue.identifier == "locationDetail" {
     
     if let indexPath = self.tableView.indexPathForSelectedRow {
     let loce = Locations[indexPath.row]
     (segue.destination as! LocationDetailViewController).detailLocation = loce
     }
     }
     
     
     
     }
    
    
    
}






/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


