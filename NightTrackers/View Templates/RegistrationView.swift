//
//  RegistrationView.swift
//  NightTrackers
//
//  Created by Codex on 3/22/26.
//

import PhotosUI
import SwiftUI
import UIKit


struct RegistrationView: View {
    let store: any UserProfileStore

    @State private var draft = RegistrationDraft()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var validationError: RegistrationValidationError?
    @State private var saveErrorMessage: String?
    @State private var isSaving = false

    private let validator = RegistrationValidator()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black, Color.neonBlue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create your NightTrackers profile")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Add your basic info now. Your profile is stored in the app's local SwiftData database so you can jump straight into the experience next time.")
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        RegistrationTextField(
                            title: "First name",
                            placeholder: "Enter your first name",
                            text: $draft.firstName,
                            error: validationError?.message(for: .firstName),
                            keyboardType: .default,
                            contentType: .givenName
                        )

                        RegistrationTextField(
                            title: "Last name",
                            placeholder: "Enter your last name",
                            text: $draft.lastName,
                            error: validationError?.message(for: .lastName),
                            keyboardType: .default,
                            contentType: .familyName
                        )

                        RegistrationTextField(
                            title: "Phone number",
                            placeholder: "5551234567",
                            text: $draft.phoneNumber,
                            error: validationError?.message(for: .phoneNumber),
                            keyboardType: .phonePad,
                            contentType: .telephoneNumber
                        )
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.neonBlue.opacity(0.5), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Photo (optional)")
                            .font(.headline)
                            .foregroundStyle(.white)

                        HStack(spacing: 20) {
                            profileImage

                            VStack(alignment: .leading, spacing: 12) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Label("Upload photo", systemImage: "photo.badge.plus")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.neonPink)

                                Button("Skip for now") {
                                    selectedPhotoItem = nil
                                    draft.photoData = nil
                                }
                                .foregroundStyle(.white.opacity(0.78))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.neonPink.opacity(0.45), lineWidth: 1)
                    )

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote.weight(.semibold))
                    }

                    Button(action: submitRegistration) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.black)
                            }

                            Text(isSaving ? "Saving..." : "Create profile")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .buttonStyle(.plain)
                    .background(Color.neonGreen)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                    .disabled(isSaving)
                    .opacity(isSaving ? 0.75 : 1)
                }
                .padding(24)
            }
        }
        .task(id: selectedPhotoItem) {
            await loadSelectedPhoto()
        }
    }

    private var profileImage: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))

                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .padding(18)
                        .foregroundStyle(Color.neonBlue)
                }
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.neonBlue.opacity(0.65), lineWidth: 2)
        )
    }

    private var uiImage: UIImage? {
        guard let photoData = draft.photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }

    @MainActor
    private func submitRegistration() {
        saveErrorMessage = nil

        do {
            let sanitizedDraft = try validator.validate(draft)
            validationError = nil
            saveErrorMessage = nil
            draft = sanitizedDraft

            isSaving = true
            _ = try store.save(sanitizedDraft)
            isSaving = false
        } catch let error as RegistrationValidationError {
            validationError = error
            isSaving = false
        } catch {
            saveErrorMessage = "We couldn't save your profile. Please try again."
            isSaving = false
        }
    }

    @MainActor
    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else {
            return
        }

        do {
            draft.photoData = try await selectedPhotoItem.loadTransferable(type: Data.self)
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "We couldn't load that image. Please choose a different photo."
        }
    }
}

private struct RegistrationTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let error: String?
    let keyboardType: UIKeyboardType
    let contentType: UITextContentType?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            Group {
                if let contentType {
                    TextField(placeholder, text: $text)
                        .textContentType(contentType)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(error == nil ? Color.white.opacity(0.08) : Color.red, lineWidth: 1)
            )
            .foregroundStyle(.white)

            if let error {
                Text(error)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.red)
            }
        }
    }
}
