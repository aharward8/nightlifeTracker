//
//  RegistrationView.swift
//  NightTrackers
//
//  Created by Codex on 3/22/26.
//

import PhotosUI
import SwiftUI
import UIKit

private enum AuthMode: String, CaseIterable, Identifiable {
    case createAccount = "Create Account"
    case signIn = "Sign In"

    var id: String { rawValue }
}

struct RegistrationView: View {
    let store: any UserProfileStore

    @State private var authMode: AuthMode = .createAccount
    @State private var draft = RegistrationDraft()
    @State private var email = ""
    @State private var password = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var validationError: RegistrationValidationError?
    @State private var emailError: String?
    @State private var passwordError: String?
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
                    header

                    Picker("Mode", selection: $authMode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if authMode == .createAccount {
                        profileFieldsSection
                        photoSection
                    }

                    authSection

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote.weight(.semibold))
                    }

                    Button(action: submit) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.black)
                            }

                            Text(buttonTitle)
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
        .onChange(of: authMode) { _, newMode in
            clearErrors()
            if newMode == .signIn {
                selectedPhotoItem = nil
                draft.photoData = nil
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(authMode == .createAccount ? "Create your NightTrackers account" : "Sign in to NightTrackers")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(headerSubtitle)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var headerSubtitle: String {
        switch authMode {
        case .createAccount:
            return "Create your NightTrackers account"
        case .signIn:
            return "Sign in with your email and password. We'll restore your saved profile from Firebase."
        }
    }

    private var profileFieldsSection: some View {
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
    }

    private var photoSection: some View {
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
    }

    private var authSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            RegistrationTextField(
                title: "Email",
                placeholder: "you@example.com",
                text: $email,
                error: emailError,
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureRegistrationField(
                title: "Password",
                placeholder: authMode == .createAccount ? "At least 6 characters" : "Enter your password",
                text: $password,
                error: passwordError
            )
        }
        .padding(20)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.neonGreen.opacity(0.45), lineWidth: 1)
        )
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

    private var buttonTitle: String {
        if isSaving {
            return authMode == .createAccount ? "Creating Account..." : "Signing In..."
        }

        return authMode == .createAccount ? "Create Account" : "Sign In"
    }

    @MainActor
    private func submit() {
        clearErrors()

        Task {
            isSaving = true

            do {
                let sanitizedEmail = try validateEmail()
                let sanitizedPassword = try validatePassword()

                switch authMode {
                case .createAccount:
                    let sanitizedDraft = try validator.validate(draft)
                    validationError = nil
                    draft = sanitizedDraft

                    try await AuthService.shared.signUp(
                        email: sanitizedEmail,
                        password: sanitizedPassword,
                        draft: sanitizedDraft
                    )
                    _ = try store.save(sanitizedDraft)

                case .signIn:
                    let remoteProfile = try await AuthService.shared.login(
                        email: sanitizedEmail,
                        password: sanitizedPassword
                    )

                    _ = try store.save(
                        RegistrationDraft(
                            firstName: remoteProfile.firstName,
                            lastName: remoteProfile.lastName,
                            phoneNumber: remoteProfile.phoneNumber
                        )
                    )
                }
            } catch let error as RegistrationValidationError {
                validationError = error
            } catch let error as AuthInputError {
                apply(error)
            } catch {
                saveErrorMessage = error.localizedDescription
            }

            isSaving = false
        }
    }

    private func validateEmail() throws -> String {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard sanitizedEmail.contains("@"), sanitizedEmail.contains(".") else {
            throw AuthInputError.email("Enter a valid email address.")
        }
        return sanitizedEmail
    }

    private func validatePassword() throws -> String {
        let sanitizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        switch authMode {
        case .createAccount:
            guard sanitizedPassword.count >= 6 else {
                throw AuthInputError.password("Password must be at least 6 characters.")
            }
        case .signIn:
            guard !sanitizedPassword.isEmpty else {
                throw AuthInputError.password("Enter your password.")
            }
        }

        return sanitizedPassword
    }

    private func apply(_ error: AuthInputError) {
        switch error {
        case .email(let message):
            emailError = message
        case .password(let message):
            passwordError = message
        }
    }

    private func clearErrors() {
        validationError = nil
        emailError = nil
        passwordError = nil
        saveErrorMessage = nil
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

private enum AuthInputError: Error {
    case email(String)
    case password(String)
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

private struct SecureRegistrationField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            SecureField(placeholder, text: $text)
                .textContentType(.password)
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
