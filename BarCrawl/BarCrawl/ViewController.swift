//
//  ViewController.swift
//  BarCrawl
//
//  Created by Michael B. Dykema on 11/15/21.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextLocation: UILabel!
    
    @IBOutlet weak var visitedLabel: UILabel!
    @IBOutlet weak var upcomingLabel: UILabel!
    
    @IBOutlet weak var prevBarButton: UIButton!
    @IBOutlet weak var nextBarButton: UIButton!
    
    var userLocation: CLLocation?
    
    var bars : [CrawlLocation] = []
    var index = 0;
    var currentBar : CrawlLocation? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        // Founder's
        addBar(lat: 42.958616864612026, lon: -85.67377688667962, name: "Founder's", code: "123")
        // Knickerbocker
        addBar(lat: 42.97131950294989, lon: -85.67987089279102, name: "The Knickerbocker", code: "abc")
        // Aperativo
        addBar(lat: 42.95698193069936, lon: -85.67095307656999, name: "Aperativo", code: "last")
        
        LOCATION_MANAGER.delegate = self
        
        if (!isAuthorized()) {
            LOCATION_MANAGER.requestWhenInUseAuthorization()
        }
        
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        
        if (bars.count > index) {
            setCurrentBar(barIndex: index)
        }
    }
    
    func isAuthorized() -> Bool {
        if (LOCATION_MANAGER.authorizationStatus == .authorizedWhenInUse ||
            LOCATION_MANAGER.authorizationStatus == .authorizedAlways) {
            return true
        }
        return false
    }

    func noAuthorization() {
        self.performSegue(withIdentifier: "noLocationSegue", sender: nil)
    }
    
    func addBar(lat: Double, lon: Double, name: String, code: String) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = CLCircularRegion(center: location, radius: 100, identifier: name)
        bars.append(CrawlLocation(name: name, code: code, region: region))
    }
    
    func setCurrentBar(barIndex: Int) {
        if (currentBar != nil) {
            mapView.removeAnnotation(currentBar!.annotation)
            currentBar?.region.notifyOnEntry = false
            currentBar?.region.notifyOnExit = false
            LOCATION_MANAGER.stopMonitoring(for: (currentBar?.region)!)
        }
        
        currentBar = bars[barIndex]
        currentBar?.region.notifyOnEntry = true
        currentBar?.region.notifyOnExit = true
        
        LOCATION_MANAGER.startMonitoring(for: (currentBar?.region)!)
                
        // Zoom the map to the current bar
        let region = MKCoordinateRegion( center: (currentBar?.region.center)!, latitudinalMeters: CLLocationDistance(exactly: 2000)!, longitudinalMeters: CLLocationDistance(exactly: 2000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        mapView.addAnnotation(currentBar!.annotation)
                
        if (bars.count - 1 > index) {
            nextLocation.text = bars[index + 1].name
        } else {
            nextLocation.text = "Home!"
        }
        
        updateCheckInEnabled()
        
        let visitedCount = bars.reduce(0, {sum, bar in
            if (bar.visited) {
                return sum + 1
            }
            return sum
        })
        visitedLabel.text = "Visited: \(visitedCount)"
        upcomingLabel.text = "Upcoming: \(bars.count - visitedCount)"
        
        nextBarButton.isEnabled = index < bars.count - 1
        prevBarButton.isEnabled = index > 0
    }
    
    @IBAction func checkIn(_ sender: Any) {
        // Make sure to actually update the bar in the array
        let alert = UIAlertController(title: "\(currentBar!.name ?? "Passcode")", message: "Enter Code", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [self] _ in
            if (currentBar?.code != alert.textFields![0].text) {
                return
            }
                        
            bars[index].visited = true
            
            index += 1
            if (index >= bars.count) {
                finishedCrawl()
                return
            }
            
            setCurrentBar(barIndex: index)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Code"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func previousBar(_ sender: Any) {
        if (index > 0) {
            index -= 1
            setCurrentBar(barIndex: index)
        }
    }
    
    @IBAction func nextBar(_ sender: Any) {
        if (index < bars.count - 1) {
            index += 1
            setCurrentBar(barIndex: index)
        }
    }
    
    func finishedCrawl() {
        self.performSegue(withIdentifier: "finishedSegue", sender: nil)
        LOCATION_MANAGER.stopUpdatingLocation()
    }
    
    func updateCheckInEnabled() {
        if (currentBar!.visited) {
            checkInButton.setTitle("Checked In!", for: .normal)
        }
        else {
            checkInButton.setTitle("Check Me In!", for: .normal)
        }
        checkInButton.isEnabled = !currentBar!.visited && (userLocation != nil && currentBar!.region.contains(userLocation!.coordinate))
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Location Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if (manager.authorizationStatus == .notDetermined) {
            return
        }
        
        if (!isAuthorized()) {
            // This may need to be changed
            noAuthorization()
        }
        else {
            LOCATION_MANAGER.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region.identifier == currentBar?.region.identifier) {
            updateCheckInEnabled()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region.identifier == currentBar?.region.identifier) {
            index += 1
            setCurrentBar(barIndex: index)
        }
        else {
            updateCheckInEnabled()
        }
    }
}

