//
//  ContentView.swift
//  NightTrackers
//
//  Created by Adam Harward on 2/9/26.
//

import SwiftUI
import UIKit

struct SettingsPage: View {
    let profile: UserProfile

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonPink.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Image("Settings Wheel")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())

                        Text("Settings")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Spacer()
                    }

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

                    Text("Profile details are stored locally in the NightTrackers app database.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink(destination: ContentView()) {
                        Text("Find All Favorites")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.neonBlue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
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
    SettingsPage(profile: UserProfile(firstName: "Taylor", lastName: "North", phoneNumber: "5551234567"))
}
