//
//  LocationFinder.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/16/26.
//  Updated by Aiden Hemmer on 4/21/26.
//

import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class VenueSearcher: ObservableObject {
    @Published private(set) var nearbyVenues: [VenueLocation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func searchForVenues(category: String, near userCoordinate: CLLocationCoordinate2D) async {
        isLoading = true
        errorMessage = nil

        let request = MKLocalSearch.Request(
            naturalLanguageQuery: query(for: category),
            region: MKCoordinateRegion(
                center: userCoordinate,
                latitudinalMeters: 5_000,
                longitudinalMeters: 5_000
            )
        )
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            let userLocation = CLLocation(
                latitude: userCoordinate.latitude,
                longitude: userCoordinate.longitude
            )

            let venues = response.mapItems.compactMap { item -> VenueLocation? in
                guard let location = item.placemark.location else {
                    return nil
                }

                let distanceMeters = userLocation.distance(from: location)
                let distanceMiles = ((distanceMeters / 1609.34) * 100).rounded() / 100

                return VenueLocation(
                    name: item.name ?? "Unknown Venue",
                    lat: location.coordinate.latitude,
                    long: location.coordinate.longitude,
                    category: displayCategory(for: category),
                    distanceMiles: distanceMiles
                )
            }

            nearbyVenues = Array(
                Dictionary(
                    venues.map {
                        (key: "\($0.name.lowercased())-\($0.lat)-\($0.long)", value: $0)
                    },
                    uniquingKeysWith: { first, _ in first }
                )
                .values
                .sorted { $0.distanceMiles < $1.distanceMiles }
                .prefix(10)
            )
        } catch {
            nearbyVenues = []
            errorMessage = "Unable to load nearby \(displayCategory(for: category).lowercased()) right now."
        }

        isLoading = false
    }

    private func query(for category: String) -> String {
        switch category.lowercased() {
        case "food":
            return "fast food"
        case "bar":
            return "bar"
        case "casino":
            return "casino"
        default:
            return category
        }
    }

    private func displayCategory(for category: String) -> String {
        switch category.lowercased() {
        case "food":
            return "Fast Food"
        case "bar":
            return "Bar"
        case "casino":
            return "Casino"
        default:
            return category
        }
    }
}
