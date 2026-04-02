import Foundation
import FirebaseFirestore
import FirebaseAuth
import MapKit

class VenueManager: ObservableObject {
    @Published var venues: [VenueLocation] = []
    @Published var favorites: [VenueLocation] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchVenuesFromDatabase(category: String = "Bar", completion: @escaping ([VenueLocation]) -> Void) {
        isLoading = true
        
        db.collection("venues")
            .whereField("category", isEqualTo: category)
            .getDocuments { [weak self] snapshot, error in
                defer { self?.isLoading = false }
                
                if let error = error {
                    print("Error fetching venues from database: \(error.localizedDescription)")
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
                    
                    return VenueLocation(
                        name: name,
                        lat: lat,
                        long: long,
                        category: venueCategory,
                        distanceMiles: 0
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    self?.venues = venues
                    completion(venues)
                }
            }
    }
    
    func addVenueToDatabase(name: String, latitude: Double, longitude: Double, category: String, address: String = "", phoneNumber: String = "") {
        let venueData: [String: Any] = [
            "name": name,
            "latitude": latitude,
            "longitude": longitude,
            "category": category,
            "address": address,
            "phoneNumber": phoneNumber,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("venues").addDocument(data: venueData) { error in
            if let error = error {
                print("Error adding venue to database: \(error.localizedDescription)")
            } else {
                print("Venue successfully added to database")
            }
        }
    }
    
    func fetchUserFavorites(completion: @escaping ([VenueLocation]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        db.collection("users").document(uid).collection("favoriteVenues")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching favorites: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let favorites = snapshot?.documents.compactMap { doc -> VenueLocation? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let lat = data["latitude"] as? Double,
                          let long = data["longitude"] as? Double,
                          let category = data["category"] as? String else {
                        return nil
                    }
                    
                    return VenueLocation(
                        name: name,
                        lat: lat,
                        long: long,
                        category: category,
                        distanceMiles: 0
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    self?.favorites = favorites
                    completion(favorites)
                }
            }
    }
    
    func deleteVenueFromDatabase(venueName: String, category: String) {
        db.collection("venues")
            .whereField("name", isEqualTo: venueName)
            .whereField("category", isEqualTo: category)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error finding venue to delete: \(error.localizedDescription)")
                    return
                }
                
                snapshot?.documents.forEach { doc in
                    self?.db.collection("venues").document(doc.documentID).delete { error in
                        if let error = error {
                            print("Error deleting venue: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
    func updateVenueInDatabase(docId: String, name: String, latitude: Double, longitude: Double, category: String, address: String = "") {
        let updateData: [String: Any] = [
            "name": name,
            "latitude": latitude,
            "longitude": longitude,
            "category": category,
            "address": address,
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection("venues").document(docId).updateData(updateData) { error in
            if let error = error {
                print("Error updating venue: \(error.localizedDescription)")
            } else {
                print("Venue successfully updated")
            }
        }
    }
}