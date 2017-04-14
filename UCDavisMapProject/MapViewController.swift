
import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    
    var detailMap: Location? {
        didSet {

        self.specficView()
            
        }
        
    }
    
    override func loadView() {
        
    self.intialView ()
        
    }
    
    
    
    func intialView () {
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 38.538224, longitude: -121.761713, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 38.538224, longitude: -121.761713)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
  
        
    }
    
    func specficView () {
        
        if let map = detailMap {
            
            let mapLat = Double(map.lat)
            let mapLng = Double(map.lng)
            
    
            let camera = GMSCameraPosition.camera(withLatitude: mapLat!, longitude: mapLng!, zoom: 18.0)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            view = mapView
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: mapLat!, longitude: mapLng!)
            marker.title = map.Name
            marker.snippet = "Australia"
            marker.map = mapView

            
        }
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
