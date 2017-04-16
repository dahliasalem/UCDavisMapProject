

import UIKit
import Foundation
import RealmSwift


class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate {
    
    
    @IBOutlet weak var tf_A: UITextField!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    let ALL_LOCATIONS_STRING = "All Locations"
    var pickerDoneClicked: Bool = true
    var isComingFromFavorites: Bool = false
    var picker : UIPickerView!
    var activeValue = "All Locations"
    var locationsTable = [Location]()
    var categoryNames = [String]()
    var reach = Reachability()
    var filteredLocations = [Location]()
    var dataLoadedState = DataLoadedState.sharedInstance
    
    let realm:Realm = try! Realm()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
    
    func updateCategories(categories: [Category]) {
        var APILocations = [String: Location]()
        
        for category in categories {
            for location in category.locations {
                APILocations[location.name] = location
                if let prevLoc = self.realm.object(ofType: Location.self, forPrimaryKey: "\(location.name)"){
                    location.isFavorite = prevLoc.isFavorite
                }
                category.locations.append(location)
            }
            Helpers.DB_insert(obj: category)
        }
        
        
        for loc in locationsTable {
            if APILocations[loc.name] == nil {
                try! realm.write {
                    realm.delete(loc)
                }
            }
        }
    }
    
    func filterContentForSearch(searchText: String, scope: String = "All"){
        
        filteredLocations = locationsTable.filter{ loc in
            return loc.name.lowercased().contains(searchText.lowercased())
            
        }
        
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        tf_A.delegate = self
        tf_A.tintColor = UIColor.clear
        tf_A.text = "All Locations"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        if isComingFromFavorites {
            self.tableView.allowsMultipleSelection = true
            reloadTableData()
            return
            
        }
        else {
            if reach.isInternetAvailable() && !dataLoadedState.isLoaded {
                debugPrint("internet is available")
                loadDataFromAPI()
                dataLoadedState.isLoaded = true
            } else {
                debugPrint("internet is not available")
                reloadTableData()
            }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if isComingFromFavorites {
            self.navigationItem.rightBarButtonItem = self.doneButton
        }
    }
    
    
    
    func loadDataFromAPI () {
        
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
                    var categories = [Category]()
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [[String:AnyObject]]
                    
                    DispatchQueue.main.async{
                        for i in 0...json.count-1 {
                            
                            let category = Category()
                            category.name = json[i]["name"] as! String
                            
                            if let stations = json[i]["locations"] as? [[String: AnyObject]] {
                                
                                for station in stations {
                                    
                                    
                                    guard let name = station["name"] as? String,
                                        let link = station["link"] as? String,
                                        var latString = station["lat"] as? String,
                                        var lngString = station["lng"] as? String else {
                                            continue
                                    }
                                    
                                    latString = latString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                    lngString = lngString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                    
                                    guard let lat = Double(latString),
                                        let lng = Double(lngString) else {
                                            continue
                                    }
                                    
                                    
                                    let location = Location()
                                    
                                    location.name = name
                                    location.link = link
                                    location.lat = lat
                                    location.lng = lng
                                    
                                    category.locations.append(location)
                                    
                                }
                            }
                            
                            categories.append(category)
                            
                        } //end loop json
                        
                        self.updateCategories(categories: categories)
                        
                        self.reloadTableData()
                    }
                    
                } catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        
        task.resume()
        
    }
    
    
    
    
    func reloadTableData() {
        
        locationsTable = Array(realm.objects(Location.self).sorted(byKeyPath: "name" , ascending: true))
        
        
        let catObjects = self.realm.objects(Category.self)
        categoryNames.append(ALL_LOCATIONS_STRING)
        
        for cat in catObjects {
            categoryNames.append(cat.name)
        }
        
        self.tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredLocations.count
        }
        
        return locationsTable.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as UITableViewCell
        
        
        var locya: Location
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
            locya = filteredLocations[indexPath.row]
        } else {
            
            locya = locationsTable[indexPath.row]
        }
        
        cell.textLabel?.text = locya.name
        
        
        if isComingFromFavorites{
            if searchController.isActive && searchController.searchBar.text != "" {
                cell.accessoryType = filteredLocations[indexPath.row].isFavorite ? .checkmark: .none
                
            } else {
                cell.accessoryType = locationsTable[indexPath.row].isFavorite ? .checkmark: .none
            }
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isComingFromFavorites {
            return
        }
        
        try! self.realm.write{
            if searchController.isActive && searchController.searchBar.text != "" {
                filteredLocations[indexPath.row].isFavorite = !filteredLocations[indexPath.row].isFavorite
                searchController.isActive = false
            } else {
                locationsTable[indexPath.row].isFavorite = !locationsTable[indexPath.row].isFavorite
                
            }
        }
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.tabBarItem.title = "title"
        //self.tabBarItem.image = "image.png"
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return !isComingFromFavorites
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "locationDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let loce: Location
                if searchController.isActive && searchController.searchBar.text != "" {
                    loce = filteredLocations[indexPath.row]
                } else {
                    loce = locationsTable[indexPath.row]
                }
                
                (segue.destination as! LocationDetailViewController).detailLocation = loce
                
            }
            
        }
        
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return categoryNames.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categoryNames[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        activeValue = categoryNames[row]
        
        if pickerDoneClicked {
            
            if categoryNames[row] == ALL_LOCATIONS_STRING {
                
                let catLocations = self.realm.objects(Location.self).sorted(byKeyPath: "name" , ascending: true )
                
                locationsTable = Array(catLocations)
                
            } else {
                
                
                let catLocations = self.realm.objects(Category.self).filter("name == '\(categoryNames[row])'").first
                
                locationsTable = Array(catLocations!.locations)
            }
            
            pickerDoneClicked = false
            
        }
        
    }
    
    
    // start editing text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        tableView.isUserInteractionEnabled = false
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
            
            row = categoryNames.index(of: currentValue)
            
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
        tableView.isUserInteractionEnabled = true
        tf_A.text = activeValue
        tf_A.resignFirstResponder()
        pickerDoneClicked = true
        self.picker.reloadInputViews()
        self.tableView.reloadData()
        
    }
    
    // cancel
    func cancelClick() {
        tableView.isUserInteractionEnabled = true
        tf_A.resignFirstResponder()
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}


