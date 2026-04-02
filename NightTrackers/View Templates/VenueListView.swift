import SwiftUI

struct VenueListView: View {
    var venues: [Venue] // An array of Venue models
    var body: some View {
        NavigationView {
            List(venues) { venue in
                NavigationLink(destination: VenueDetailView(venue: venue)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(venue.name)
                                .font(.headline)
                            Text("\(venue.category) - \(venue.distance) mi")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Venues")
        }
    }
}

// Sample model for Venue
struct Venue: Identifiable {
    var id: UUID
    var name: String
    var category: String
    var distance: Double
}

// Placeholder for VenueDetailView
struct VenueDetailView: View {
    var venue: Venue
    var body: some View {
        Text(venue.name)
    }
}