//  LocationPermissionGate.swift
//  NightTrackers

import SwiftUI
import CoreLocation

struct LocationPermissionGate<Content: View>: View {
    @ObservedObject var locationManager: LocationManager
    let content: Content

    init(locationManager: LocationManager, @ViewBuilder content: () -> Content) {
        self.locationManager = locationManager
        self.content = content()
    }

    var body: some View {
        switch locationManager.authorizationStatus {

        case .notDetermined:
            // Haven't asked yet — show our custom prompt
            LocationRequestView(locationManager: locationManager)

        case .denied, .restricted:
            // User said no — tell them how to fix it
            LocationDeniedView()

        case .authorizedWhenInUse, .authorizedAlways:
            // All good — show the real app
            content

        @unknown default:
            LocationRequestView(locationManager: locationManager)
        }
    }
}

// MARK: - "Please Allow Location" Screen

struct LocationRequestView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonBlue.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                Image(systemName: "location.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(Color.neonBlue)
                    .shadow(color: .neonBlue, radius: 20)

                VStack(spacing: 12) {
                    Text("NightTrackers needs your location")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("We use your location to find nearby bars, restaurants, and point you in the right direction — all in real time.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                Button(action: {
                    locationManager.requestPermission()
                }) {
                    Text("Allow Location Access")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.neonGreen)
                        .clipShape(Capsule())
                        .shadow(color: .neonGreen.opacity(0.5), radius: 10)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - "Location is Blocked" Screen

struct LocationDeniedView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonRed.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                Image(systemName: "location.slash.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(Color.neonRed)
                    .shadow(color: .neonRed, radius: 20)

                VStack(spacing: 12) {
                    Text("Location access is off")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("NightTrackers can't work without your location. Turn it on in Settings to continue.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                Button(action: {
                    // Deep-links the user directly to this app's Settings page
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.neonRed)
                        .clipShape(Capsule())
                        .shadow(color: .neonRed.opacity(0.5), radius: 10)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}