//
//  favoritesManager.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/27/26.
//

import Foundation

@MainActor
final class FavoritesManager: ObservableObject {
    @Published var items: [Favorite] = []

    func isFavorite(placeName: String) -> Bool {
        items.contains(where: { $0.locationName == placeName })
    }

    func favorite(named locationName: String) -> Favorite? {
        items.first(where: { $0.locationName == locationName })
    }

    func upsert(locationName: String, lat: Double, long: Double, remoteID: String? = nil) {
        if let index = items.firstIndex(where: { $0.locationName == locationName }) {
            items[index].lat = lat
            items[index].long = long
            if let remoteID {
                items[index].remoteID = remoteID
            }
        } else {
            items.append(Favorite(remoteID: remoteID, locationName: locationName, lat: lat, long: long))
        }
    }

    func remove(locationName: String) {
        items.removeAll { $0.locationName == locationName }
    }

    func replaceAll(with favorites: [Favorite]) {
        items = favorites
    }
}
