//
//  ContentView.swift
//  NightTrackers
//
//  Created by Adam Harward on 2/9/26.
//

import SwiftUI

struct SettingsPage: View {
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // This fills the entire screen
            VStack {
                HStack{
                    Image("Settings Wheel")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    
                    Text("Settings")
                        .foregroundColor(.white)
                    
                    Image("Settings Wheel")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                Spacer()
                
                NavigationLink(destination: FavoritesView(favorites: MockData.food + MockData.bars))
                {
                    HStack {
                        Image("Favorites Liked")
                            .resizable()
                            .frame(width: 60, height: 60)
                        
                        Text("Find All Favorites")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image("Favorites Liked")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .stroke(Color.neonBlue, lineWidth: 3)
                            .shadow(color: .neonBlue, radius: 10)
                            .shadow(color: .neonBlue.opacity(0.6), radius: 15)
                    )
                    .padding(.horizontal)
                }
                .padding()
                
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .stroke(Color.neonPink, lineWidth: 3)
                            .shadow(color: .neonPink, radius: 10)
                    )
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showLogoutConfirmation) {
                        PopUpView(text:"Are you sure you want to log out? This will take you back to the login screen.", title: "Log Out")
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                }
                .padding()
                
                
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .stroke(Color.neonRed, lineWidth: 3)
                            .shadow(color: Color.neonRed, radius: 10)
                    )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showDeleteConfirmation) {
                    PopUpView(text:" This will permanently remove your nightlife history and all saved favorites. This action cannot be undone.", title: "Delete Account")
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    SettingsPage()
}
