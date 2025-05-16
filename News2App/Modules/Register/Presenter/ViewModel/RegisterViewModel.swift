//
//  RegisterViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine
import Foundation
import SwiftUICore

class RegisterViewModel: ObservableObject {
    @Published var emailField: CustomTextFieldViewModel
    @Published var passwordField: CustomTextFieldViewModel
    @Published var registerButton: CustomButtonViewModel

    private let registerUseCase: RegisterUseCase
    private var cancellables = Set<AnyCancellable>()

    init(registerUseCase: RegisterUseCase = RegisterUseCaseImpl()) {
        self.registerUseCase = registerUseCase
        emailField = CustomTextFieldViewModel(config: Self.makeEmailFieldConfig())
        passwordField = CustomTextFieldViewModel(config: Self.makePasswordFieldConfig())
        registerButton = CustomButtonViewModel(config: Self.makeRegisterButtonConfig())

        setupBindings()
        setupRegisterButtonAction()
    }

    private func setupBindings() {
        Publishers.CombineLatest(emailField.$text, passwordField.$text)
            .sink { [weak self] _, _ in
                guard let self = self else { return }
                self.updateRegisterButtonState()
            }
            .store(in: &cancellables)
    }

    private func setupRegisterButtonAction() {
        registerButton.config.action = { [weak self] in
            self?.register()
        }
    }

    private func updateRegisterButtonState() {
        let isFormValid = emailField.isValid && passwordField.isValid
        registerButton.config.isDisabled = !isFormValid
        objectWillChange.send()
    }

    private static func makeEmailFieldConfig() -> CustomTextFieldConfiguration {
        return CustomTextFieldConfiguration(
            title: "Email",
            placeholder: "Enter Email",
            isSecure: false,
            validationType: .email
        )
    }

    private static func makePasswordFieldConfig() -> CustomTextFieldConfiguration {
        return CustomTextFieldConfiguration(
            title: "Password",
            placeholder: "Enter Password",
            isSecure: true,
            validationType: .password
        )
    }

    private static func makeRegisterButtonConfig() -> CustomButtonConfiguration {
        return CustomButtonConfiguration(
            title: "Register",
            backgroundColor: .orange,
            isDisabled: true,
            isLoading: false,
            action: {}
        )
    }

    func register() {
        registerButton.config.isLoading = true
        registerUseCase.register(
            email: emailField.text,
            password: passwordField.text
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.registerButton.config.isLoading = false
                switch result {
                case .success:
                    print("Register success")
                case .failure:
                    print("Register failed")
                }
                self?.objectWillChange.send()
            }
        }
    }
}
