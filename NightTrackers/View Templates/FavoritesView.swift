//
//  FavoritesView.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/16/26.
//

import SwiftUI

struct FavoritesView: View {
    @State var favorites: [Place]
    
    // 1. Create an array of your custom colors to cycle through
    let themeColors: [Color] = [.neonRed, .neonBlue, .neonPink, .neonGreen, .neonPurple]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Favorites Table")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 2. Use .enumerated() so we get both the 'index' (row number) and the 'favorite' data
                        ForEach(Array(favorites.enumerated()), id: \.element.id) { index, favorite in
                            
                            // 3. The Math Magic: This ensures the index never goes out of bounds of your color array
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
                                
                                Text(favorite.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Lat: \(String(format: "%.2f", favorite.location.lat))")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Long: \(String(format: "%.2f", favorite.location.long))")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 10)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                Capsule()
                                    // 4. Swap out the hardcoded color for your new dynamic 'rowColor'
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
                
                Spacer()
            }
        }
    }
    
    func removeFavorite(_ place: Place) {
        favorites.removeAll { $0.id == place.id }
    }
}
#Preview {
    // Updated the preview to use our new struct
    FavoritesView(favorites: MockData.bars + MockData.food
    )
}
