import Foundation
import FirebaseFirestore

struct VenueLocation {
    var name: String
    var coordinates: (latitude: Double, longitude: Double)
    var category: String
    var distance: Double
    var ratings: Float
    var address: String

    private var db = Firestore.firestore()

    // Initialize the VenueLocation
    init(name: String, coordinates: (Double, Double), category: String, distance: Double, ratings: Float, address: String) {
        self.name = name
        self.coordinates = coordinates
        self.category = category
        self.distance = distance
        self.ratings = ratings
        self.address = address
    }

    // Function to save VenueLocation to Firestore
    func save() {
        let venueData: [String: Any] = [
            "name": name,
            "coordinates": [
                "latitude": coordinates.latitude,
                "longitude": coordinates.longitude
            ],
            "category": category,
            "distance": distance,
            "ratings": ratings,
            "address": address
        ]
        
        db.collection("venues").addDocument(data: venueData) { error in
            if let error = error {
                print("Error saving venue: \(error)")
            } else {
                print("Venue saved successfully!")
            }
        }
    }

    // Function to fetch venues from Firestore
    static func fetchVenues(completion: @escaping ([VenueLocation]) -> Void) {
        var venues: [VenueLocation] = []
        
        db.collection("venues").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching venues: \(error)")
                completion(venues)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                if let name = data["name"] as? String,
                   let coords = data["coordinates"] as? [String: Double],
                   let category = data["category"] as? String,
                   let distance = data["distance"] as? Double,
                   let ratings = data["ratings"] as? Float,
                   let address = data["address"] as? String {
                    let venue = VenueLocation(
                        name: name,
                        coordinates: (latitude: coords["latitude"] ?? 0.0, longitude: coords["longitude"] ?? 0.0),
                        category: category,
                        distance: distance,
                        ratings: ratings,
                        address: address
                    )
                    venues.append(venue)
                }
            }
            
            completion(venues)
        }
    }
}