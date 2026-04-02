import SwiftUI
import MapKit

struct VenueMapView: View {
    let venues: [VenueLocation]
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedVenue: VenueLocation?
    @Environment(\"\dismiss\") var dismiss
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedVenue) {
                ForEach(venues) { venue in
                    Marker(venue.name, coordinate: CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.long))
                        .tint(colorForCategory(venue.category))
                        .tag(venue)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: \"xmark.circle.fill\")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if !venues.isEmpty {
                            position = .automatic
                        }
                    }) {
                        Image(systemName: \"location.circle.fill\")
                            .font(.system(size: 28))
                            .foregroundColor(.neonBlue)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(16)
                
                Spacer()
                
                if let selectedVenue = selectedVenue {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedVenue.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            Label(\"\(selectedVenue.distanceMiles) mi\", systemImage: \"location.fill\")
                                .font(.caption)
                                .foregroundColor(.neonBlue)
                            
                            Label(selectedVenue.category, systemImage: \"tag.fill\")
                                .font(.caption)
                                .foregroundColor(.neonPink)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(16)
                }
            }
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case \"bar\":
            return .neonBlue
        case \"restaurant\":
            return .neonGreen
        case \"club\":
            return .neonPink
        case \"fast food\":
            return .orange
        default:
            return .neonBlue
        }
    }
}

#Preview {
    VenueMapView(venues: [
        VenueLocation(name: \"Sample Bar\", lat: 38.2975, long: -84.8733, category: \"Bar\", distanceMiles: 0.5)
    ])
}