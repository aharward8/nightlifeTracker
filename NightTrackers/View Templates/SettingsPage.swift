//
//  ContentView.swift
//  NightTrackers
//
//  Created by Adam Harward on 2/9/26.
//

import SwiftUI

struct SettingsPage: View {
    let profile: UserProfile
    let onLogout: () async throws -> Void
    let onDeleteProfile: () async throws -> Void
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonPink.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()


                VStack{
                    HStack(spacing: 24) {
                        profileImage
                        
                        VStack(alignment: .leading, spacing: 16) {
                            settingsRow(title: "First name", value: profile.firstName)
                            settingsRow(title: "Last name", value: profile.lastName)
                            settingsRow(title: "Phone number", value: profile.phoneNumber)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.neonPink.opacity(0.45), lineWidth: 1)
                        )
                        Spacer()
                    }
                        Spacer()
                    
                    //TODO: Need a data for favorites
                    NavigationLink(destination: FavoritesView()) {
                        Text("Find All Favorites")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.neonBlue)
                                    .shadow(color: .neonBlue, radius: 10)
                            )
                    }
                    Spacer()

                    Button(action: { showLogoutConfirmation = true }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.neonPink)
                                    .shadow(color: .neonPink, radius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showLogoutConfirmation) {
                        PopUpView(
                            text: "Are you sure you want to log out?",
                            title: "Log Out",
                            buttonColor: .neonPink,
                            action: onLogout
                        )
                            .presentationDetents([.medium])
                    }
                    Spacer()

                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Delete Account")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color.neonRed)
                                .shadow(color: Color.neonRed, radius: 10)
                        )
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showDeleteConfirmation) {
                        PopUpView(
                            text: "This will permanently remove your local profile and saved favorites. This action cannot be undone.",
                            title: "Delete Account",
                            buttonColor: .neonRed,
                            action: onDeleteProfile
                        )
                            .presentationDetents([.medium])
                    }
                    Spacer()
                }
                .padding(.horizontal)
        }
    }

    private var profileImage: some View {
        Group {
            if let photoData = profile.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.neonPink)
                    .padding(16)
            }
        }
        .frame(width: 120, height: 120)
        .background(Color.white.opacity(0.06))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.neonPink.opacity(0.65), lineWidth: 2)
        )
    }

    private func settingsRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))

            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingsPage(
        profile: UserProfile(firstName: "Taylor", lastName: "North", phoneNumber: "5551234567"),
        onLogout: {},
        onDeleteProfile: {}
    )
        .environmentObject(FavoritesManager())
}
