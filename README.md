# Core-Location-Demo
*Author: Michael Dykema*

## Overview

Core Location is a iOS framework used to track user's location. The framework provides functionality to request access to the user's location, fetch user location, receive updates when user moves or enters a specified area, and more. The demo app used to demostrate some of this functionality is a bar crawl app used to verify that the user has visited the necessary locations. 



## Getting Started

This demo was written on/for Xcode 13.1 and iOS 15. No other dependencies or Pods necessary.

[Download and install Xcode from here.](https://developer.apple.com/xcode/)

[Here is the official Apple documentation for Core Location.](https://developer.apple.com/documentation/corelocation)

This app also uses the MapView from iOS's MapKit. [Reference if needed.](https://developer.apple.com/documentation/mapkit)



## Step-by-Step Coding Instructions

### Creating the project

Create a new App in Xcode.

This app is built using storyboards so be sure to *Storyboard* under *Interface* options. 

This tutorial assumes a basic understanding of creating interfaces using Storyboards and concepts such as but not limited to [segues](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html), [AutoLayout](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/index.html), IBActions and IBOutlets.

### Layout



### Location Manager





### Testing

There are two ways to test this app. The first and most practical is to use Xcode's built-in simulator. When using the simulator there are two main ways to simulate location. 

##### Custom Location

With the simulator open and in the foreground, select *Features > Location > Custom Location*.

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

If this tutorial/project has interested you and you wish to experiment more with Core Location, one should look at integrating Core Location with [MapKit](https://developer.apple.com/documentation/mapkit/). We utilized MapView from MapKit in a very basic way, but there is much more to MapKit and the two frameworks can do a lot of cool things together. 

### Source Code

[Here is the full source code for the demo app.](https://github.com/HobbesMD/Core-Location-Demo)
