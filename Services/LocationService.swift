import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var nearbyVenues: [VenueLocation] = []
    @Published var isTrackingLocation = false
    
    private var locationManager: CLLocationManager
    private let db = Firestore.firestore()
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTrackingUserLocation() {
        isTrackingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func stopTrackingUserLocation() {
        isTrackingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location
        }
        saveLocationToFirestore(location)
    }
    
    private func saveLocationToFirestore(_ location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date()),
            "accuracy": location.horizontalAccuracy
        ]
        
        db.collection("users").document(uid).collection("locations").addDocument(data: locationData) { error in
            if let error = error {
                print("Error saving location: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNearbyVenues(category: String = "Bar", radiusMiles: Double = 3.1, completion: @escaping ([VenueLocation]) -> Void) {
        guard let userLocation = userLocation else {
            completion([])
            return
        }
        
        let radiusMeters = radiusMiles * 1609.34
        
        db.collection("venues")
            .whereField("latitude", isGreaterThan: userLocation.coordinate.latitude - 0.1)
            .whereField("latitude", isLessThan: userLocation.coordinate.latitude + 0.1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching venues: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let venues = snapshot?.documents.compactMap { doc -> VenueLocation? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let lat = data["latitude"] as? Double,
                          let long = data["longitude"] as? Double,
                          let venueCategory = data["category"] as? String else {
                        return nil
                    }
                    
                    let venueLocation = CLLocation(latitude: lat, longitude: long)
                    let distance = userLocation.distance(from: venueLocation)
                    
                    if distance <= radiusMeters && venueCategory.lowercased().contains(category.lowercased()) {
                        let distanceMiles = ((distance / 1609.34) * 100).rounded() / 100
                        return VenueLocation(name: name, lat: lat, long: long, category: venueCategory, distanceMiles: distanceMiles)
                    }
                    return nil
                } ?? []
                
                DispatchQueue.main.async {
                    self.nearbyVenues = venues.sorted { $0.distanceMiles < $1.distanceMiles }
                    completion(self.nearbyVenues)
                }
            }
    }
    
    func saveSearchHistory(searchTerm: String, category: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let historyData: [String: Any] = [
            "searchTerm": searchTerm,
            "category": category,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).collection("searchHistory").addDocument(data: historyData) { error in
            if let error = error {
                print("Error saving search history: \(error.localizedDescription)")
            }
        }
    }
    
    func saveFavoriteVenue(venueName: String, latitude: Double, longitude: Double, category: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let favoriteData: [String: Any] = [
            "name": venueName,
            "latitude": latitude,
            "longitude": longitude,
            "category": category,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).collection("favoriteVenues").addDocument(data: favoriteData) { error in
            if let error = error {
                print("Error saving favorite venue: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFavoriteVenue(venueId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("favoriteVenues").document(venueId).delete { error in
            if let error = error {
                print("Error removing favorite venue: \(error.localizedDescription)")
            }
        }
    }
}