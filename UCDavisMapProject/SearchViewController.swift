

import UIKit
import Foundation
import RealmSwift


class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
   
    
    @IBOutlet weak var tf_A: UITextField!
    @IBOutlet var tableView : UITableView!
    
    var doneCalled: Bool = true
    
    var picker : UIPickerView!
    var activeValue = "All Locations"
    
    var Locations = [Location]()
   
  
    var CategoryNames = [String]()
    let realm:Realm = try! Realm()
    var reach = Reachability()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredLocations = [Location]()

    

    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }

  
    
    func filterContentForSearch(searchText: String, scope: String = "All"){
        
        filteredLocations = Locations.filter{ loc in
            return loc.Name.lowercased().contains(searchText.lowercased())
        
        }
        
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tf_A.delegate = self
        tf_A.tintColor = UIColor.clear
        tf_A.text = "All Locations"
        //tableView.isUserInteractionEnabled = false

        
        // var NSURLSession : NSURLSession
         //self.dropDown.isHidden = true
        if reach.isInternetAvailable() == true {
            
            //print("yes")
            try! realm.write {
                realm.deleteAll()
            }
            parseJSON()
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            tableView.tableHeaderView = searchController.searchBar
            
            
        } else {
            
            queryRealm()
            
        }
        
        
    }
    
    func doneClicked () {
        
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
                        self.queryRealm ()
                        self.tableView.reloadData()
                        //self.picker.reloadAllComponents()
                    }
                    
                    
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
                
            }
        }
        
        task.resume()
        
        
        
        
    }
    
    
    
    
    func queryRealm () {
        
        //let catya = Category()
        
        //catya.name = "All Locations"
        
        //var counter = 0
       
        
        // initial way of cleaning Realm DB
        let cleanUP = realm.objects(Location.self).sorted(byKeyPath: "Name" , ascending: true )

        
        for i in 0 ..< cleanUP.count-100  {
            
            
            if cleanUP[i].Name == cleanUP[i+1].Name{
                //counter += 10
                print("first if")
                try! realm.write {
                    realm.delete(cleanUP[i+1])
                    print("inside")
                    
                }
            }
            
        }
        
        
        let LocObjects = try! Realm().objects(Location.self)
        let LocByName = LocObjects.sorted(byKeyPath: "Name" , ascending: true )
        
        
        
        
        
        
        for loc in LocByName {
            Locations.append(loc)
            }
        
        let CatObjects = try! Realm().objects(Category.self)
        CategoryNames.append("All Locations")
    
        for cat in CatObjects {
            CategoryNames.append(cat.name)
                    }
        
       // let array = Array(Categories[0].locations)
        
        //debugPrint(Categories[0])
        print("here")
        //debugPrint(array)
        
        //Locations = Array(Categories[0].locations)
        
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredLocations.count
        }
        
        return Locations.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as UITableViewCell
        
        
        var locya: Location
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
            locya = filteredLocations[indexPath.row]
        } else {
            
             locya = Locations[indexPath.row]
        }
        
       
        
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
                let loce: Location
                if searchController.isActive && searchController.searchBar.text != "" {
                    loce = filteredLocations[indexPath.row]
                } else {
                    loce = Locations[indexPath.row]
                }
                
                (segue.destination as! LocationDetailViewController).detailLocation = loce
                
            }
            
        }
        
    }
    
    
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return CategoryNames.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return CategoryNames[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
         activeValue = CategoryNames[row]
        
        if doneCalled == true {
            
            if CategoryNames[row] == "All Locations" {
                
                let myPuppy = realm.objects(Location.self).sorted(byKeyPath: "Name" , ascending: true )
                
                Locations = Array(myPuppy)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }
            

            
           
            if CategoryNames[row] == "Student & Staff Resources" {
                
                let myPuppy = realm.objects(Category.self).filter("name == 'Student & Staff Resources'").first
                
                Locations = Array(myPuppy!.locations)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }

            
    
            if CategoryNames[row] == "Housing & Dining" {
                
                let myPuppy = realm.objects(Category.self).filter("name == 'Housing & Dining'").first
                
                Locations = Array(myPuppy!.locations)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }
            

            
            
            if CategoryNames[row] == "Places of Interest" {
                
                let myPuppy = realm.objects(Category.self).filter("name == 'Places of Interest'").first
                
                Locations = Array(myPuppy!.locations)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }
            
            
            if CategoryNames[row] == "Recreation" {
                
                let myPuppy = realm.objects(Category.self).filter("name == 'Recreation'").first
                
                Locations = Array(myPuppy!.locations)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }
            
            
            
            if CategoryNames[row] == "Buildings" {
                
                let myPuppy = realm.objects(Category.self).filter("name == 'Buildings'").first
                
                Locations = Array(myPuppy!.locations)
                //self.tableView.reloadData()
                //self.dropDown.reloadAllComponents()
                
            }
            
            
            doneCalled = false
            
        }
        
                debugPrint("picker view")
        
    }

    
    
    
    // start editing text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //activeTextField = 1
        
        // set active Text Field
        tf_A = textField
        
        self.pickUpValue(textField: textField)
        
    }
    
    // show picker view
    func pickUpValue(textField: UITextField) {
        
        // create frame and size of picker view
        picker = UIPickerView(frame:CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
        
        // deletates
        picker.delegate = self
        picker.dataSource = self
        
        // if there is a value in current text field, try to find it existing list
        
        
        if let currentValue = textField.text {
            
            var row : Int?
            
            // look in correct array
            
            row = CategoryNames.index(of: currentValue)
            
            // we got it, let's set select it
            if row != nil {
                picker.selectRow(row!, inComponent: 0, animated: true)
            }
        }
        
        picker.backgroundColor = UIColor.white
        textField.inputView = self.picker
        
        // toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = UIColor.darkGray
        toolBar.sizeToFit()
        
        // buttons for toolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    // done
    func doneClick() {
        tf_A.text = activeValue
        tf_A.resignFirstResponder()
        doneCalled = true
        self.picker.reloadInputViews()
        self.tableView.reloadData()
        
    }
    
    // cancel
    func cancelClick() {
        tf_A.resignFirstResponder()
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


