//
//  NavagationView.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/9/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct NavagationView: View {
    let viewType: String
    let theme: Color
    let names: [Place]
    @StateObject var locationManager = LocationManager()
    @StateObject var searcher = VenueSearcher()
    @State private var currentIndex = 0
    
    var view: String {
        switch viewType {
        case "Food":
            return "Food Search"
        case "Bar":
            return "Bar Search"
        case "Friends":
            return "Friends"
        default:
            return "Default"
        }
    }
    
    var body: some View {
        // 1. Capture the user's location once so the code below is much cleaner to read
        let userLat = locationManager.userLocation?.coordinate.latitude ?? MockData.currentLocation.lat
        let userLong = locationManager.userLocation?.coordinate.longitude ?? MockData.currentLocation.long
        let currentPlace = names[currentIndex]
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // --- TOP NAVIGATION BAR ---
                HStack {
                    Button(action: {
                        currentIndex = (currentIndex > 0) ? currentIndex - 1 : names.count - 1
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.neonBlue)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(currentPlace.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .id(currentIndex)
                        .transition(.opacity)
                    
                    Spacer()
                    
                    Button(action: {
                        currentIndex = (currentIndex < names.count - 1) ? currentIndex + 1 : 0
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .foregroundColor(.neonBlue)
                            .padding()
                    }
                }
                .padding()
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .background(Color.black.opacity(0.5))
                )
                .animation(.default, value: currentIndex)
                
                Spacer()
                
                // --- ARROW AND DISTANCE ---
                VStack(spacing: 20) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 300))
                        .foregroundColor(.neonBlue)
                        // 2. Uses our clean variables instead of the massive inline fallback
                        .rotationEffect(.degrees(
                            calculateBearing(from: (lat: userLat, long: userLong),
                                             to: (lat: currentPlace.location.lat, long: currentPlace.location.long))
                        ))
                        .animation(.spring(), value: currentIndex)
                        .onTapGesture {
                            openInMaps(latitude: currentPlace.location.lat, longitude: currentPlace.location.long, name: currentPlace.name)
                        }
                    
                    // 3. Calculate distance and display it directly below the arrow
                    let distance = currentPlace.distanceInFeet(from: (lat: userLat, long: userLong))
                    Text(formatDistance(distance))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Helper Functions

func openInMaps(latitude: Double, longitude: Double, name: String) {
    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let placemark = MKPlacemark(coordinate: coordinates)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = name
    
    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
}

func calculateBearing(from: (lat: Double, long: Double), to: (lat: Double, long: Double)) -> Double {
    let lat1 = from.lat * .pi / 180
    let lon1 = from.long * .pi / 180
    let lat2 = to.lat * .pi / 180
    let lon2 = to.long * .pi / 180

    let dLon = lon2 - lon1
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    
    let radians = atan2(y, x)
    return radians * 180 / .pi
}

// 4. Smart formatting: Converts to miles if the distance is over 5,280 feet
func formatDistance(_ feet: Double) -> String {
    if feet >= 5280 {
        let miles = feet / 5280
        return String(format: "%.1f miles away", miles)
    } else {
        return String(format: "%.0f ft away", feet)
    }
}

#Preview {
    // Replaced .neonPurple with .neonBlue to match your arrow (or change it to whatever your theme requires!)
    NavagationView(viewType: "Food",
                   theme: .blue,
                   names: MockData.food)
}
