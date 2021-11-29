//
//  CrawlLocation.swift
//  BarCrawl
//
//  Created by Michael B. Dykema on 11/15/21.
//

import Foundation
import CoreLocation
import MapKit

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
