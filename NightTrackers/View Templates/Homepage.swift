//
//  ContentView.swift
//  NightTrackers
//
//  Created by Adam Harward on 2/9/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    VStack{
                        ZStack{
                            Image("App Icon usage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            HStack{
                                Spacer()
                                NavigationLink(destination: SettingsPage()) {
                                    Image("Settings Wheel")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal)
                        }
                        Text("Welcome back \"UserName\"")
                            .foregroundColor(.blue)
                    
                        Spacer()
                    
                    NavigationLink(destination: ContentView()) {
                        Text("Go To Nearest Bar")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                    Capsule()
                                        .stroke(Color.neonBlue, lineWidth: 2)
                                        .shadow(color: .neonBlue, radius: 4)
                                        .shadow(color: .neonBlue.opacity(0.6), radius: 10)
                                )
                            .shadow(color: .neonBlue.opacity(0.8), radius: 5)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    NavigationLink(destination: ContentView()) {
                        Text("Go To Nearest Bar")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                    Capsule()
                                        .stroke(Color.neonPink, lineWidth: 2)
                                        .shadow(color: .neonPink, radius: 4)
                                        .shadow(color: .neonPink.opacity(0.6), radius: 10)
                                )
                            .shadow(color: .neonPink.opacity(0.8), radius: 5)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    Text("Find Nearest Fast Food")
                        .padding()
                        .foregroundColor(.white)
	
                    Spacer()
                    
                }
            }
        }
    }
        }


#Preview {
    HomeView()
}
