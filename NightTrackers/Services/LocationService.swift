import CoreLocation
database import Firestore

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    private var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // Start tracking user location
    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    // Stop tracking user location
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location
        // Update location in Firestore
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

    // Fetch nearby venues by category
    func fetchNearbyVenues(category: String, completion: @escaping ([Venue]) -> Void) {
        guard let location = userLocation else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        db.collection("venues").whereField("category", isEqualTo: category)
            .getDocuments { (snapshot, error) in
                var venues: [Venue] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        let venue = Venue(data: data)
                        venues.append(venue)
                    }
                }
                completion(venues)
            }
    }

    // Save search history
    func saveSearchHistory(query: String) {
        let searchHistoryData: [String: Any] = [
            "query": query,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("searchHistory").addDocument(data: searchHistoryData)
    }

    // Manage favorite venues
    func addFavorite(venueId: String) {
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("favorites").document(venueId).setData([:])
    }

    func removeFavorite(venueId: String) {
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "unknown")").collection("favorites").document(venueId).delete()
    }
}