//
//  LocationFinder.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/16/26.
//  Updated by Aiden Hemmer on 4/1/26.
//

import SwiftUI
import MapKit
import CoreLocation


class VenueSearcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Updated to store full venue info instead of just tuples
    @Published var nearbyVenues: [VenueLocation] = []
    @Published var userLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Only search if we haven't found venues yet (runs on app open)
        if nearbyVenues.isEmpty {
            self.userLocation = location
            searchForVenues(category: "Bar")
        }
    }
    
    // Generic search function for different categories (Bars, Food, etc.)
    func searchForVenues(category: String) {
        guard let location = userLocation else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            // Map the Apple results and calculate distance for each venue
            let results: [VenueLocation] = response.mapItems.compactMap { item in
                let venueName = item.name ?? "Unknown Venue"
                let venueLat = item.placemark.coordinate.latitude
                let venueLong = item.placemark.coordinate.longitude
                
                // Create CLLocation for distance calculation
                let venueLocation = CLLocation(latitude: venueLat, longitude: venueLong)
                
                // Calculate straight-line distance (meters -> miles)
                let distanceMeters = location.distance(from: venueLocation)
                let distanceMiles = ((distanceMeters / 1609.34) * 100).rounded() / 100
                
                return VenueLocation(
                    name: venueName,
                    lat: venueLat,
                    long: venueLong,
                    category: category,
                    distanceMiles: distanceMiles
                )
            }
            
            // Sort venues by closest distance and take top 10
            let sortedResults = results
                .sorted { $0.distanceMiles < $1.distanceMiles }
                .prefix(10)
            
            DispatchQueue.main.async {
                self.nearbyVenues = Array(sortedResults)
            }
        }
    }
}
