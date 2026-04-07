//
//  NavagationView.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/9/26.
//

import CoreLocation
import MapKit
import SwiftUI

struct NavagationView: View {
    let viewType: String
    let theme: Color
    @ObservedObject var locationManager: LocationManager

    @StateObject private var searcher = VenueSearcher()
    @State private var currentIndex = 0

    private var screenTitle: String {
        switch viewType {
        case "Food":
            return "Food Search"
        case "Bar":
            return "Bar Search"
        case "Friends":
            return "Friends"
        default:
            return "Nearby Places"
        }
    }

    private var currentVenue: VenueLocation? {
        guard searcher.nearbyVenues.indices.contains(currentIndex) else {
            return nil
        }

        return searcher.nearbyVenues[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let userLocation = locationManager.userLocation {
                content(for: userLocation)
                    .task(id: searchTaskID(for: userLocation)) {
                        await reloadVenues(near: userLocation)
                    }
            } else {
                waitingForLocationView
            }
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(for userLocation: CLLocation) -> some View {
        if searcher.isLoading && searcher.nearbyVenues.isEmpty {
            ProgressView("Finding nearby \(viewType.lowercased()) spots...")
                .tint(theme)
                .foregroundStyle(.white)
        } else if let errorMessage = searcher.errorMessage, searcher.nearbyVenues.isEmpty {
            messageView(
                title: "Search failed",
                message: errorMessage,
                buttonTitle: "Try Again"
            ) {
                Task {
                    await reloadVenues(near: userLocation)
                }
            }
        } else if let venue = currentVenue {
            loadedView(userLocation: userLocation, venue: venue)
        } else {
            messageView(
                title: "No nearby results",
                message: "Try again in a moment or move to a busier area."
            )
        }
    }

    private func loadedView(userLocation: CLLocation, venue: VenueLocation) -> some View {
        VStack {
            HStack {
                Button(action: showPreviousVenue) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                        .foregroundColor(theme)
                        .padding()
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(venue.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("\(currentIndex + 1) of \(searcher.nearbyVenues.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.65))
                }
                .id(currentIndex)
                .transition(.opacity)

                Spacer()

                Button(action: showNextVenue) {
                    Image(systemName: "chevron.right")
                        .font(.title2.bold())
                        .foregroundColor(theme)
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

            VStack(spacing: 20) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 300))
                    .foregroundColor(theme)
                    .rotationEffect(.degrees(
                        calculateBearing(
                            from: (
                                lat: userLocation.coordinate.latitude,
                                long: userLocation.coordinate.longitude
                            ),
                            to: (lat: venue.lat, long: venue.long)
                        )
                    ))
                    .animation(.spring(), value: currentIndex)
                    .onTapGesture {
                        openInMaps(latitude: venue.lat, longitude: venue.long, name: venue.name)
                    }

                Text(formatDistance(venue.distanceMiles * 5_280))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding()
    }

    private var waitingForLocationView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(theme)
                .scaleEffect(1.2)

            Text("Waiting for your location...")
                .font(.headline)
                .foregroundColor(.white)

            Text("NightTrackers needs your current location before it can find places nearby.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private func messageView(
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(theme)
            }
        }
    }

    private func reloadVenues(near userLocation: CLLocation) async {
        await searcher.searchForVenues(
            category: viewType,
            near: userLocation.coordinate
        )
        currentIndex = 0
    }

    private func searchTaskID(for location: CLLocation) -> String {
        let latitude = String(format: "%.4f", location.coordinate.latitude)
        let longitude = String(format: "%.4f", location.coordinate.longitude)
        return "\(viewType)-\(latitude)-\(longitude)"
    }

    private func showPreviousVenue() {
        guard !searcher.nearbyVenues.isEmpty else {
            return
        }

        currentIndex = currentIndex > 0 ? currentIndex - 1 : searcher.nearbyVenues.count - 1
    }

    private func showNextVenue() {
        guard !searcher.nearbyVenues.isEmpty else {
            return
        }

        currentIndex = currentIndex < searcher.nearbyVenues.count - 1 ? currentIndex + 1 : 0
    }
}

func openInMaps(latitude: Double, longitude: Double, name: String) {
    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let placemark = MKPlacemark(coordinate: coordinates)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = name

    mapItem.openInMaps(
        launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    )
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

func formatDistance(_ feet: Double) -> String {
    if feet >= 5_280 {
        let miles = feet / 5_280
        return String(format: "%.1f miles away", miles)
    } else {
        return String(format: "%.0f ft away", feet)
    }
}

#Preview {
    NavagationView(viewType: "Food", theme: .blue, locationManager: LocationManager())
}
