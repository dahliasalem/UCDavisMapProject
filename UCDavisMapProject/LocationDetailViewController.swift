

import UIKit
import MapKit
import AddressBook

class LocationDetailViewController: UIViewController {

    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var locTitle = "Something"
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    
    @available(iOS 10.0, *)
    @IBAction func directions(_ sender: Any) {
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
    
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
    
        
        let placemark = MKPlacemark(coordinate: coordinates)
            
        
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locTitle
        mapItem.openInMaps(launchOptions: options)
        
        
        
    }
    

    
    var detailLocation: Location? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let location = detailLocation {

            self.latitude = Double(location.lat)!
            self.longitude = Double(location.lng)!
            self.locTitle = location.Name
            
            title = "INFO"
            
            let basicDetails = "\(location.Name)\n"
            
           
            
            detailDescriptionLabel?.text = basicDetails
            
            
            
        }
    }
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapDetail" {
        
                let loce = detailLocation
                (segue.destination as! MapViewController).detailMap = loce
            
        }
        
        
        
    }
    

}
