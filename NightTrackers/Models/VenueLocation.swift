//
//  VenueLocation.swift
//  NightTrackers

import Foundation

struct VenueLocation: Identifiable, Hashable {
    let id: UUID
    var name: String
    var lat: Double
    var long: Double
    var category: String
    var distanceMiles: Double

    init(name: String, lat: Double, long: Double, category: String, distanceMiles: Double = 0) {
        self.id = UUID()
        self.name = name
        self.lat = lat
        self.long = long
        self.category = category
        self.distanceMiles = distanceMiles
    }
}
