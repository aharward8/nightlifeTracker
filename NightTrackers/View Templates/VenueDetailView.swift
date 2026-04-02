import SwiftUI
import MapKit

struct VenueDetailView: View {
    var venue: Venue // Assuming Venue is a model containing venue information
    @State private var isFavorite: Bool = false // For saving as favorite

    var body: some View {
        ScrollView {
            VStack {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: venue.location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)), 
                    interactionModes: [])
                    .frame(height: 300)
                    .cornerRadius(10)
                
                Text(venue.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(venue.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Distance: \(venue.distance) miles")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Category: \(venue.category)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    isFavorite.toggle()
                }) {
                    Text(isFavorite ? "Remove from Favorites" : "Save as Favorite")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(isFavorite ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitle("Venue Details", displayMode: .inline)
    }
}

// Dummy Venue model for demonstration
struct Venue {
    var name: String
    var address: String
    var distance: String
    var category: String
    var location: CLLocation // Assuming location contains coordinate info
}