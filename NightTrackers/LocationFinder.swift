//
//  LocationFinder.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/16/26.
//

import SwiftUI
import MapKit
import CoreLocation

class VenueSearcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var nearbyBars: [(name: String, lat: Double, long: Double)] = []
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
        
        // Only search if we haven't found bars yet or if the user moved significantly
        if nearbyBars.isEmpty {
            self.userLocation = location
            searchForBars(near: location)
        }
    }
    
    func searchForBars(near location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Bar"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            // Map the Apple results into your Tuple format
            let results = response.mapItems.prefix(10).map { item in
                (
                    name: item.name ?? "Unknown Bar",
                    lat: item.placemark.coordinate.latitude,
                    long: item.placemark.coordinate.longitude
                )
            }
            
            DispatchQueue.main.async {
                self.nearbyBars = Array(results)
            }
        }
    }
}
