import MapKit
import FirebaseFirestore

class VenueSearchManager {
    var venues: [Venue] = []
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?

    init() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func searchVenues(category: String, completion: @escaping ([Venue]) -> Void) {
        let db = Firestore.firestore()
        db.collection("venues")
            .whereField("category", isEqualTo: category)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching venues: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                self.venues = documents.compactMap { try? $0.data(as: Venue.self) }
                completion(self.venues)
            }
    }

    func calculateDistances() {
        guard let userLocation = userLocation else { return }
        for venue in venues {
            let venueLocation = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
            let distance = calculateDistance(from: userLocation, to: venueLocation)
            venue.distance = distance
        }
    }

    private func calculateDistance(from location1: CLLocationCoordinate2D, to location2: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let loc2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return loc1.distance(from: loc2) // distance in meters
    }

    func filterVenues(with criterion: (Venue) -> Bool) -> [Venue] {
        return venues.filter(criterion)
    }
}

extension VenueSearchManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        calculateDistances()
    }
}

struct Venue: Codable {
    var name: String
    var category: String
    var latitude: Double
    var longitude: Double
    var distance: Double?
}