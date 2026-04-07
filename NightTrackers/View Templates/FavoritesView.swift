import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesManager: FavoritesManager

    @State private var isLoading = false
    @State private var errorMessage: String?

    let themeColors: [Color] = [.neonRed, .neonBlue, .neonPink, .neonGreen, .neonPurple]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonPink.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Text("Favorites Table")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(Array(favoritesManager.items.enumerated()), id: \.element.id) { index, favorite in
                            let rowColor = themeColors[index % themeColors.count]

                            HStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        removeFavorite(favorite)
                                    }
                                }) {
                                    Image("Favorites Liked")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }

                                Text(favorite.locationName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Lat: \(String(format: "%.2f", favorite.lat))")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))

                                    Text("Long: \(String(format: "%.2f", favorite.long))")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 10)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                Capsule()
                                    .stroke(rowColor, lineWidth: 10)
                                    .shadow(color: rowColor, radius: 15)
                                    .shadow(color: rowColor.opacity(0.6), radius: 20)
                            )
                            .shadow(color: rowColor.opacity(0.8), radius: 5)
                            .clipShape(Capsule())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .overlay {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else if favoritesManager.items.isEmpty {
                        Text("No favorites yet!")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.headline)
                    }
                }

                Spacer()
            }
        }
        .task {
            await loadFavorites()
        }
    }

    private func loadFavorites() async {
        isLoading = true
        errorMessage = nil

        do {
            let remoteFavorites = try await FirestoreService.shared.fetchFavorites()
            favoritesManager.replaceAll(
                with: remoteFavorites.map {
                    Favorite(
                        remoteID: $0.id,
                        locationName: $0.locationName,
                        lat: $0.lat,
                        long: $0.long
                    )
                }
            )
        } catch {
            FirestoreService.shared.logFavoriteError(error, action: "load")
            errorMessage = FirestoreService.shared.favoriteErrorMessage(for: error, action: "loaded")
        }

        isLoading = false
    }

    private func removeFavorite(_ favorite: Favorite) {
        favoritesManager.remove(locationName: favorite.locationName)

        guard let remoteID = favorite.remoteID else {
            return
        }

        Task {
            do {
                try await FirestoreService.shared.removeFavorite(documentID: remoteID)
            } catch {
                FirestoreService.shared.logFavoriteError(error, action: "remove")
                favoritesManager.upsert(
                    locationName: favorite.locationName,
                    lat: favorite.lat,
                    long: favorite.long,
                    remoteID: favorite.remoteID
                )
                errorMessage = FirestoreService.shared.favoriteErrorMessage(for: error, action: "removed")
            }
        }
    }
}

#Preview {
    let manager = FavoritesManager()
    manager.items = [
        Favorite(locationName: "Neon Club", lat: 34.05, long: -118.24),
        Favorite(locationName: "Midnight Diner", lat: 34.06, long: -118.25)
    ]

    return FavoritesView()
        .environmentObject(manager)
}
