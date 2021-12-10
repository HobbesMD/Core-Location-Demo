# Core-Location-Demo
*Author: Michael Dykema*

## Overview

Core Location is a iOS framework used to track user's location. The framework provides functionality to request access to the user's location, fetch user location, receive updates when user moves or enters a specified area, and more. The demo app used to demostrate some of this functionality is a bar crawl app used to verify that the user has visited the necessary locations. 

![Demo.gif](/Assets/Demo.gif)


## Getting Started

This demo was written on/for Xcode 13.1 and iOS 15. No other dependencies or Pods necessary.

[Download and install Xcode from here.](https://developer.apple.com/xcode/)

[Here is the official Apple documentation for Core Location.](https://developer.apple.com/documentation/corelocation)

This app also uses the MapView from iOS's MapKit. [Reference if needed.](https://developer.apple.com/documentation/mapkit)



## Step-by-Step Coding Instructions

### Creating the project

Create a new App in Xcode.

This app is built using storyboards so be sure to *Storyboard* under *Interface* options. 

This tutorial assumes a basic understanding of creating interfaces using Storyboards and concepts such as but not limited to [delegates](https://www.tutorialspoint.com/ios/ios_delegates.htm), [segues](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html), [AutoLayout](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/index.html), [IBActions and IBOutlets](https://www.tutorialspoint.com/ios/ios_actions_and_outlets.htm#:~:text=Actions%20and%20outlets%20in%20iOS,visually%20how%20to%20implement%20them.).

### Layout

This app utilizes three views. The main view is layed out as follows:

<img src="/Assets/MainView.png" alt="MainView" height="600"/>

The Previous and Next Bar are buttons, as well as the Check In. Visited, Completed, Next Bar, and the name of the next bar are all labels. The blue rectangle in the middle of the screen is a MapView.


There is a modal unauthorized view (presented modally) to demonstrate recognizing when the app does not have access to the user's location:

<img src="/Assets/UnauthorizedView.png" alt="UnauthorizedView" height="600"/>

Finally another modal view for when the user completes the bar crawl:

<img src="/Assets/FinishedView.png" alt="FinishedView" height="600"/>

And all of them together:

<img src="/Assets/FullStoryboard.png" alt="FullStoryboard" height="600"/>

### Bars

We need to keep track of which bars are to be visited, where they are, the code to confirm drink purchase, and have they been visited. Create a custom class CrawlLocation.swift.
```
struct CrawlLocation {
    var name : String!
    var code : String!
    var visited : Bool!
    var region : CLCircularRegion!
    var annotation : MKAnnotation!
    
    init (name: String, code: String, region: CLCircularRegion) {
        self.name = name
        self.code = code
        self.region = region
        visited = false
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = region.center
        pointAnnotation.title = name
        annotation = pointAnnotation
    }
}
```

We will keep track of the list of bars in the ViewController:
```
var bars : [CrawlLocation] = []
var index = 0;
var currentBar : CrawlLocation? = nil
```

To make things simple, we will create a function to add bars to be visited. Since this app is meant to demonstrate the functionality and uses of Core Locaiton, we will hard-code in the locations and not persist anything in a database or similar (though feel free to make these changes to enhance the usability of the app).
```
func addBar(lat: Double, lon: Double, name: String, code: String) {
    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    let region = CLCircularRegion(center: location, radius: 100, identifier: name)
    bars.append(CrawlLocation(name: name, code: code, region: region))
}
```

We are using CLCircularRegion, which is an implementation of CLRegion, so that we can track when a user enters or leaves a bar. A circular region simply uses a center point, which is a CLLocationCoordinate2D (essentially a lat/long pair), and a radius. The radius is in meters and 100m should be plenty. 

I used 3 bars from the Grand Rapids area, though feel free to use your own local bars. These are added in the `ViewController.viewDidLoad()`
```
// Founder's
addBar(lat: 42.958616864612026, lon: -85.67377688667962, name: "Founder's", code: "123")
// Knickerbocker
addBar(lat: 42.97131950294989, lon: -85.67987089279102, name: "The Knickerbocker", code: "abc")
// Aperativo
addBar(lat: 42.95698193069936, lon: -85.67095307656999, name: "Aperativo", code: "last")

if (bars.count > index) {
    setCurrentBar(barIndex: index)
}
```

We also need a way to change the bars so lets make a method for that.
```
func setCurrentBar(barIndex: Int) {
    currentBar = bars[barIndex]

    if (bars.count - 1 > index) {
        nextLocation.text = bars[index + 1].name
    } else {
        nextLocation.text = "Home!"
    }

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
```

And while we're at it let's add our IBActions so we can navigate between bars with our buttons:
```
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
```

And of course we need a check-in button where the user will be prompted to enter a unique code for each bar that they will receive upon beverage purchase.
```
@IBAction func checkIn(_ sender: Any) {
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
```

<img src="/Assets/Passcode.png" alt="Passcode" width="300"/>

### Location Manager

The key component to using Core Location in an iOS app is an instance of CLLocationManager. The location manager is how you ask read and ask for permissions, configure and get updates about the user's location, set up region monitoring and beacon ranging, receive updates for compass heading changes, and handle errors. This tutorial covers prompting and handling permissions, location updates, region monitoring, and error handling. Beacon ranging is rather specific and generally used in commerical settings.

#### Setting Up Location Manager

The location manager delegate must be assigned an object that follows the delegate protocol. For this tutorial we will instantiate the CLLocationManager as a global variable in the default AppDelegate.swift. Add `let LOCATION_MANAGER = CLLocationManager()` above the AppDelegate class. 

Next we have to have a class implement the CLLocaitonManagerDelegate. We will use the ViewController.swift and create an extension to implement the delegate protocol. 
```
extension ViewController : CLLocationManagerDelegate {
}
````

Finally, we must set the location manager's delegate property by setting it to the ViewController in the ViewController.swift's viewDidLoad(): `LOCATION_MANAGER.delegate = self`

#### Error Handling

Now that we have the location manager instantiated and delegate set up, we can start implementing the protocol. The first thing we should do as good practice is set up the error handling. The method that gets called when the location manager encounters an exception is `func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)`. We will make it so an alert is shown whenever we encounter an issue:
```
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    let alert = UIAlertController(title: "Location Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")
    }))
    self.present(alert, animated: true, completion: nil)
}
```

#### Asking for Permission

Before we can start getting the user's location, the user first has to give our app permission to use their location. The location manager makes this relatively simple. There are two main types of authorization for location services, `authorizedAlways` and `authorizedWhenInUse`. `authorizedWhenInUse` only allows an app access to the user's location while the app is in use and is the [preferred/recommended option by Apple](https://developer.apple.com/documentation/corelocation/choosing_the_location_services_authorization_to_request). This mode still gives the majority of apps the functionality they needs and helps to reduce battery consumption as well as ease privacy concerns of the user. An app only has to prompt the user for permissions once and will remain the same unless the user changes permissions in their phone settings. 

This app only needs in use access so we prompt for them in ViewController's viewDidLoad. If the app is loaded again after the user has been prompted, LOCATION_MANAGER.requestWhenInUseAuthorization() will do nothing.

```
if (!isAuthorized()) {
    LOCATION_MANAGER.requestWhenInUseAuthorization()
}
```


<img src="/Assets/PermissionPrompt.png" alt="PermissionPrompt" height="600"/>

Next we need to implement the isAuthorized() method we just referenced. We will use this method to determine if we are able to get the user's location.
```
func isAuthorized() -> Bool {
    if (LOCATION_MANAGER.authorizationStatus == .authorizedWhenInUse ||
        LOCATION_MANAGER.authorizationStatus == .authorizedAlways) {
        return true
    }
    return false
}
```

Finally, we need to do handle when the authorization status of our app changes. This event fires when the user selects an option for location authorization or the user changes the authorization in their settings. 
```
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if (manager.authorizationStatus == .notDetermined) {
        return
    }

    if (!isAuthorized()) {
        noAuthorization()
    }
    else {
        LOCATION_MANAGER.startUpdatingLocation()
    }
}
```

If we are not authorized, we want to present a view saying the app doesn't have access to the user's location and therefore the app will not work. This will be handled in noAuthorization(). 
```    
func noAuthorization() {
    self.performSegue(withIdentifier: "noLocationSegue", sender: nil)
}
```

#### Getting User Location

When our app has permissions to access the user's location, we want to start receiving updates as they move, which is why in `func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)` we called `LOCATION_MANAGER.startUpdatingLocation()`. This will start the standard location service which offers the programmer the most control over when updates are sent, but is the most power-consuming way to get updates. If desired, we could change the location manager's `.desiredAccuracy`, which determine's how precise our location information will be. Additionally, if we wanted less frequent updates we could change the `.distanceFilter` which by default is set to `kCLDistanceFilterNone` which means we will be notified on all movements. Since our app needs to know exactly when the user is in the bar, we will leave these values at their default. 

Alternatives to `LOCATION_MANAGER.startUpdatingLocation()` are `LOCATION_MANAGER.startMonitoringVisits()` and `LOCATION_MANAGER.startMonitoringSignificantLocationChanges()`. Visits service keeps track of user information such as how long they spend at a particular location, which could be useful if the bars wanted to know how long patrons were spending at their bar during their crawl but it is not useful for realtime information. Significant-Change service only sends updates after the user have moved a "significant amount, such as 500 meters or more", which is not accurate enough for our use.

Finally, we need to handle user location updates and we can do so with:
```
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    userLocation = locations.last
}
```

Because our app uses region-monitoring, we don't actually need to do anything other than note the last-known location of the user.
```
var userLocation: CLLocation?
```

Finally, when the app is done using the user's location, in our case when the crawl is finished, we can call `LOCATION_MANAGER.stopUpdatingLocation()` to stop receiving updates about the user's location.
```
func finishedCrawl() {
    self.performSegue(withIdentifier: "finishedSegue", sender: nil)
    LOCATION_MANAGER.stopUpdatingLocation()
}
```

#### Region Monitoring

Now we want to get notified when the user enters or leaves the bar. We can do this through region monitoring. We have already created the regions for our bars, so now we just need to enable monitoring the current bar. The location manager will take of all the monitoring for us, all we have to do is indicate which region(s) we want monitored and implement the patterns for receiving enter and exit events. These methods are `func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)` and `func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)` and they will give us which region was entered/exited. From there we can update the status of the check-in button to reflect whether or not the user is at the correct location.

```
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

//... In regular ViewController.Swift
func updateCheckInEnabled() {
    if (currentBar!.visited) {
        checkInButton.setTitle("Checked In!", for: .normal)
    }
    else {
        checkInButton.setTitle("Check Me In!", for: .normal)
    }
    checkInButton.isEnabled = !currentBar!.visited && (userLocation != nil && currentBar!.region.contains(userLocation!.coordinate))
}
```

The last bit we need to do for region monitoring to work is to start and stop monitoring when we switch the current bar. So at the beginning of `setCurrentBar(barIndex: Int)`, we need to add the following:
```
if (currentBar != nil) {
    currentBar?.region.notifyOnEntry = false
    currentBar?.region.notifyOnExit = false
    LOCATION_MANAGER.stopMonitoring(for: (currentBar?.region)!)
}

currentBar = bars[barIndex]
currentBar?.region.notifyOnEntry = true
currentBar?.region.notifyOnExit = true

LOCATION_MANAGER.startMonitoring(for: (currentBar?.region)!)
```


### MapView

This tutorial is about Core Location and this app would function without any sort of map, but it does make the app look better so we'll quickly update our MapView from the MapKit framework. I won't go into much detail about how MapView works but if you're interested, in addition to the Apple documentation, [raywanderlich.com](https://www.raywenderlich.com/7738344-mapkit-tutorial-getting-started) and [iosapptemplates.com](https://iosapptemplates.com/blog/swift-programming/mapkit-tutorial) both have great tutorials on learning more about maps in iOS.

For our purposes, we just need to add the reference to the MKMapView in our ViewController: `@IBOutlet weak var mapView: MKMapView!`

Then we want to configure it in our `viewDidLoad()`:
```
mapView.showsBuildings = true
mapView.showsUserLocation = true
mapView.isZoomEnabled = true
```

Then when we change bars we want the map to move to the current bar. So we remove the annotation with 
```
if (currentBar != nil) {
    mapView.removeAnnotation(currentBar!.annotation)
}
``` 

And then we can set the new region and our map should be working.

```
let region = MKCoordinateRegion( center: (currentBar?.region.center)!, latitudinalMeters: CLLocationDistance(exactly: 2000)!, longitudinalMeters: CLLocationDistance(exactly: 2000)!)
mapView.setRegion(mapView.regionThatFits(region), animated: true)
mapView.addAnnotation(currentBar!.annotation)
```

### Testing

There are two ways to test this app. The first and most practical is to use Xcode's built-in simulator. When using the simulator there are two main ways to simulate location. 

##### Custom Location

With the simulator open and in the foreground, select *Features > Location > Custom Location*.

<img src="/Assets/SelectingCustomLocation.png" alt="SelectingCustomLocation" height="400"/>

This will open a window asking for a coordinate pair.

*There are also a few standard locations that Apple provides that could be used instead of custom locations if desired.*

#### GPX Files

GPX files can be used to simulate movement and a few other neat things, but are beyond what is necessary for sufficient testing of this app and therefore will not be covered in depth in this project. However, if one wishes to learn more about how to use GPX files I suggest reading [this tutorial by Sarun Wongpatcharapakorn.](https://sarunw.com/posts/how-to-simulate-location-in-xcode-and-simulator/)



## Further Discussion

### Summary of Demo App

At this point if you've been following along you now have a functional app demonstrating some of the key features of iOS Core Location. Our app asks for permission from the user to their location while the app is open, tracks user movement to change the current bar and enable/disable the check-in button, and displays the user's location on a map in the app. 

### Alternatives

There are no alternatives to getting the user's location other than using Core Location in iOS. Privacy and security are principles core to Apple as a company and so they don't let expose any other way to get location data. However, if one desires a simpler/easier way to work with the LocationManager they can check out [SwiftLocation.](https://cocoapods.org/pods/SwiftLocation)

### Supplements

If this tutorial/project has interested you and you wish to experiment more with Core Location, one should look at integrating Core Location with [MapKit](https://developer.apple.com/documentation/mapkit/). We utilized MapView from MapKit in a very basic way, but there is much more to MapKit and the two frameworks can do a lot of cool things together. Additionally, there are two more features included in Core Location that were not covered in this app. They are Beacon Ranging, [which deals with locating nearby beacons](https://developer.apple.com/documentation/corelocation/ranging_for_beacons), and Compass Heading, [which provides information about the device's relation to true north](https://developer.apple.com/documentation/corelocation/getting_heading_and_course_information).

### Source Code

[Here is the full source code for the demo app.](https://github.com/HobbesMD/Core-Location-Demo)
