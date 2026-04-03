import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    private var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location
        updateLocationInFirestore(location: location)
    }

    private func updateLocationInFirestore(location: CLLocation) {
        let userLocationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").setData(userLocationData, merge: true)
    }

    func fetchNearbyVenues(category: String, completion: @escaping ([VenueLocation]) -> Void) {
        guard let location = userLocation else { return }

        db.collection("venues").whereField("category", isEqualTo: category)
            .getDocuments { (snapshot, error) in
                var venues: [VenueLocation] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let name = data["name"] as? String,
                           let lat = data["latitude"] as? Double,
                           let long = data["longitude"] as? Double {
                            let venue = VenueLocation(name: name, lat: lat, long: long, category: category)
                            venues.append(venue)
                        }
                    }
                }
                completion(venues)
            }
    }

    func saveSearchHistory(query: String) {
        let searchHistoryData: [String: Any] = [
            "query": query,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("searchHistory").addDocument(data: searchHistoryData)
    }

    func addFavorite(venueId: String) {
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("favorites").document(venueId).setData([:])
    }

    func removeFavorite(venueId: String) {
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("favorites").document(venueId).delete()
    }
}