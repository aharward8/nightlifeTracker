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
                    Spacer()
                    
                    //TODO: need to connect real location and real name locations found
                    NavigationLink(destination: NavagationView(viewType: "Bar", theme: Color.neonBlue, names: MockData.bars )) {
                        Text("Go To Nearest Bar")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                    Capsule()
                                        .stroke(Color.neonBlue, lineWidth: 10)
                                        .shadow(color: .neonBlue, radius: 15)
                                        .shadow(color: .neonBlue.opacity(0.6), radius: 20)
                                )
                            .shadow(color: .neonBlue.opacity(0.8), radius: 5)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    .padding(.horizontal)
                    Spacer()
                    
                    //TODO: need to connect real location and real name locations found
                    NavigationLink(destination: NavagationView(viewType: "Friends", theme: Color.neonPink, names: MockData.friends )) {
                        Text("Where Could My Friends Be?")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                    Capsule()
                                        .stroke(Color.neonPink, lineWidth: 10)
                                        .shadow(color: .neonPink, radius: 15)
                                        .shadow(color: .neonPink.opacity(0.6), radius: 20)
                                )
                            .shadow(color: .neonPink.opacity(0.8), radius: 5)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    .padding(.horizontal)
                    Spacer()
                    
                    //TODO: need to connect real location and real name locations found
                    NavigationLink(destination: NavagationView(viewType: "Food", theme: Color.neonPurple, names: MockData.food)) {
                        Text("I'm Starving")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                    Capsule()
                                        .stroke(Color.neonPurple, lineWidth: 10)
                                        .shadow(color: .neonPurple, radius: 15)
                                        .shadow(color: .neonPurple.opacity(0.6), radius: 20)
                                )
                            .shadow(color: .neonPurple.opacity(0.8), radius: 5)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
	
                    Spacer()
                    
                }
            }
        }
    }
        }


#Preview {
    HomeView()
}
