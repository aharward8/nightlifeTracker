//
//  Favorites.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/27/26.
//

import Foundation

class Favorite: Identifiable, Codable {
    var id = UUID()
    var remoteID: String?
    var locationName: String
    var lat: Double
    var long: Double

    init(remoteID: String? = nil, locationName: String, lat: Double, long: Double) {
        self.remoteID = remoteID
        self.locationName = locationName
        self.lat = lat
        self.long = long
    }
}
