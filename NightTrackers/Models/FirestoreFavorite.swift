//
//  FirestoreFavorite.swift
//  NightTrackers
//
//  Created by Nathan Edwards on 03/25/26.
//

import Foundation

struct FirestoreFavorite: Identifiable {
    let id: String
    let locationName: String
    let lat: Double
    let long: Double
}
