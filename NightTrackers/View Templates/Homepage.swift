//  Homepage.swift
//  NightTrackers

import SwiftUI

struct HomeView: View {
    let profile: UserProfile
    @ObservedObject var locationManager: LocationManager
    let onLogout: () async throws -> Void
    let onDeleteProfile: () async throws -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonPurple.opacity(0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    HStack(spacing: 16) {
                        profilePhoto

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.72))

                            Text(profile.firstName)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Ready to map out tonight?")
                                .foregroundStyle(Color.neonBlue)
                        }
                    }

                    Spacer()

                    NavigationLink(destination: SettingsPage(
                        profile: profile,
                        onLogout: onLogout,
                        onDeleteProfile: onDeleteProfile
                    )) {
                        Image("Settings Wheel")
                            .resizable()
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 12)

                Spacer()

                NavigationLink(destination: NavagationView(
                    viewType: "Bar",
                    theme: .neonBlue,
                    locationManager: locationManager
                )) {
                    HomeActionButton(title: "Go To Nearest Bar", accentColor: .neonBlue)
                }

                NavigationLink(destination: NavagationView(
                    viewType: "Food",
                    theme: .neonPink,
                    locationManager: locationManager
                )) {
                    HomeActionButton(title: "Find Nearest Fast Food", accentColor: .neonPink)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private var profilePhoto: some View {
        Group {
            if let photoData = profile.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("App Icon usage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 92, height: 92)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
    }
}

private struct HomeActionButton: View {
    let title: String
    let accentColor: Color

    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .stroke(accentColor, lineWidth: 2)
                    .shadow(color: accentColor, radius: 4)
                    .shadow(color: accentColor.opacity(0.6), radius: 10)
            )
            .shadow(color: accentColor.opacity(0.8), radius: 5)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

//#Preview {
//    HomeView(
//        profile: UserProfile(firstName: "Taylor", lastName: "North", phoneNumber: "5551234567"),
//        locationManager: LocationManager()
//    )
//}
