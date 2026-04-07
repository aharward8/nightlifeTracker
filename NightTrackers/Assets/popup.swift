//
//  popup.swift
//  NightTrackers
//
//  Created by Adam Harward on 3/9/26.
//

import SwiftUI

struct PopUpView: View {
    @Environment(\.dismiss) private var dismiss

    let text: String
    let title: String
    let buttonColor: Color
    let action: () async throws -> Void

    @State private var isPerformingAction = false
    @State private var errorMessage: String?

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

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: performAction) {
                HStack(spacing: 12) {
                    if isPerformingAction {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(isPerformingAction ? "Working..." : title)
                        .bold()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .disabled(isPerformingAction)

            Button("Cancel") {
                dismiss()
            }
            .disabled(isPerformingAction)
            .foregroundColor(.white)
            .font(.footnote)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.1).ignoresSafeArea())
    }

    private func performAction() {
        errorMessage = nil
        isPerformingAction = true

        Task {
            do {
                try await action()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }

            isPerformingAction = false
        }
    }
}

#Preview {
    PopUpView(
        text: "This will permanently remove your nightlife history and all saved favorites. This action cannot be undone.",
        title: "Delete Account",
        buttonColor: .red
    ) {
    }
}
