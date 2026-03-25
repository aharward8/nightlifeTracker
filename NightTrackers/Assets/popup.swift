//
//  popup.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/9/26.
//

import SwiftUI

struct PopUpView: View {
    @Environment(\.dismiss) var dismiss
    let text: String
    let title: String
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Are you sure?")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            // THE DESTRUCTIVE BUTTON
            Button(action: {
                // Perform actual delete logic here
                print("Account Deleted")
            }) {
                Text(title)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

            // THE "GET ME OUT OF HERE" BUTTON
            Button("Cancel") {
                dismiss() // Closes the sheet
            }
            .foregroundColor(.white)
            .font(.footnote)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.1).ignoresSafeArea()) // Dark background for the sheet
    }
}
#Preview {
    PopUpView(text:" This will permanently remove your nightlife history and all saved favorites. This action cannot be undone.", title: "Delete Account")
}
