//
//  VenueListView.swift
//  NightTrackers

import SwiftUI

struct VenueListView: View {
    var venues: [VenueLocation]

    var body: some View {
        NavigationView {
            List(venues) { venue in
                NavigationLink(destination: VenueDetailView(venue: venue)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(venue.name)
                                .font(.headline)
                            Text("\(venue.category) - \(venue.distanceMiles, specifier: "%.2f") mi")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Venues")
        }
    }
}