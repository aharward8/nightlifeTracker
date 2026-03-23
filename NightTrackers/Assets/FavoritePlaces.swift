//
//  FavoritePlaces.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/23/26.
//

import Foundation
import CoreLocation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let location: (lat: Double, long: Double)
}

extension Place {
    // This function takes in a starting coordinate and returns the distance in feet
    func distanceInFeet(from startCoordinate: (lat: Double, long: Double)) -> Double {
        
        // 1. Convert your simple tuples into Apple's official CLLocation objects
        let startingPoint = CLLocation(latitude: startCoordinate.lat, longitude: startCoordinate.long)
        let destination = CLLocation(latitude: self.location.lat, longitude: self.location.long)
        
        // 2. Calculate the distance in meters (Apple's default)
        let distanceInMeters = startingPoint.distance(from: destination)
        
        // 3. Convert meters to feet
        return distanceInMeters * 3.28084
    }
}

