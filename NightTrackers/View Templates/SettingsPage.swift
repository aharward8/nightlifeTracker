//
//  ContentView.swift
//  NightTrackers
//
//  Created by Adam Harward on 2/9/26.
//

import SwiftUI

struct SettingsPage: View {
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
                
                NavigationLink(destination: ContentView()) {
                    Text("Find All Favorites")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.neonBlue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                Spacer()
                    
            }
            
            
        }
    }
}

#Preview {
    SettingsPage()
}
