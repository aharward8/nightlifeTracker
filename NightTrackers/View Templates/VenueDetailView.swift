//
//  VenueDetailView.swift
//  NightTrackers

import SwiftUI
import MapKit

struct VenueDetailView: View {
    var venue: VenueLocation

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.long),
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                ))))
                .frame(height: 300)
                .cornerRadius(10)

                Text(venue.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(venue.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("\(venue.distanceMiles, specifier: "%.2f") miles away")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationBarTitle("Venue Details", displayMode: .inline)
    }
}