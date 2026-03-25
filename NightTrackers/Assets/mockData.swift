//
//  mockData.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/23/26.
//

import Foundation

struct MockData {
    
    // Your central mock location to use across the app for distance/directions
    // Set near the center of campus
    static let currentLocation = (lat: 38.0382, long: -84.5045)
    
    static let food: [Place] = [
        Place(name: "Joe Bologna's", location: (lat: 38.0401, long: -84.5024)),
        Place(name: "Tolly-Ho", location: (lat: 38.0321, long: -84.5085)),
        Place(name: "Bourbon n' Toulouse", location: (lat: 38.0305, long: -84.4912)),
        Place(name: "Goodfellas Pizzeria", location: (lat: 38.0425, long: -84.5011)),
        Place(name: "Local Taco", location: (lat: 38.0315, long: -84.5002)),
        Place(name: "Carson's Food & Drink", location: (lat: 38.0435, long: -84.4925)),
        Place(name: "KSBar and Grille", location: (lat: 38.0325, long: -84.5165)),
        Place(name: "Ramsey's Diner", location: (lat: 37.9995, long: -84.5055)),
        Place(name: "Pies & Pints", location: (lat: 38.0445, long: -84.4985)),
        Place(name: "Puccini's", location: (lat: 38.0255, long: -84.4955))
    ]
    
    static let bars: [Place] = [
        Place(name: "Tin Roof", location: (lat: 38.0395, long: -84.5042)),
        Place(name: "Stagger Inn", location: (lat: 38.0452, long: -84.4981)),
        Place(name: "McCarthy's Irish Bar", location: (lat: 38.0441, long: -84.4975)),
        Place(name: "The Paddock", location: (lat: 38.0405, long: -84.5015)),
        Place(name: "Bluegrass Tavern", location: (lat: 38.0465, long: -84.4995)),
        Place(name: "Centro", location: (lat: 38.0455, long: -84.4965)),
        Place(name: "Harvey's Bar", location: (lat: 38.0448, long: -84.4972)),
        Place(name: "The Rosebud Bar", location: (lat: 38.0432, long: -84.4968)),
        Place(name: "Banners", location: (lat: 37.9985, long: -84.5075)),
        Place(name: "Campus Pub", location: (lat: 38.0285, long: -84.5155))
    ]
    
    static let friends: [Place] = [
            Place(name: "Sarah's Apartment", location: (lat: 38.0310, long: -84.5020)),
            Place(name: "Jake's House", location: (lat: 38.0410, long: -84.4910)),
            Place(name: "Liam's Dorm", location: (lat: 38.0295, long: -84.5050)),
            Place(name: "Emily's Place", location: (lat: 38.0355, long: -84.5120)),
            Place(name: "Marcus's Townhouse", location: (lat: 38.0180, long: -84.5250))
        ]
}

