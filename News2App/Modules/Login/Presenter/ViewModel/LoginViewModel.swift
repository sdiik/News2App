//
//  LoginViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine
import Auth0
import SwiftUICore

class LoginViewModel: ObservableObject {
    @Published var title: CustomTextViewModel
    @Published var emailField: CustomTextFieldViewModel
    @Published var passwordField: CustomTextFieldViewModel
    @Published var loginButton: CustomButtonViewModel
    @Published var description: CustomTextViewModel
    @Published var isLoginSuccess: Bool = false
    
    private let loginUseCase: LoginUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(loginUseCase: LoginUseCase = LoginUseCaseImpl()) {
        self.loginUseCase = loginUseCase
        self.title = CustomTextViewModel(config: Self.makeTitleConfig())
        self.emailField = CustomTextFieldViewModel(config: Self.makeEmailFieldConfig())
        self.passwordField = CustomTextFieldViewModel(config: Self.makePasswordFieldConfig())
        self.loginButton = CustomButtonViewModel(config: Self.makeLoginButtonConfig())
        self.description = CustomTextViewModel(config: Self.makeDescConfig())
        
        setupBindings()
        setupButtonAction()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest(emailField.$text, passwordField.$text)
            .sink { [weak self] _, _ in
                guard let self = self else { return }
                self.updateLoginButtonState()
            }
            .store(in: &cancellables)
    }
    
    private func setupButtonAction() {
        loginButton.config.action = { [weak self] in
            self?.login()
        }
    }
    
    private func updateLoginButtonState() {
        let isFormValid = emailField.isValid && passwordField.isValid
        loginButton.config.isDisabled = !isFormValid
        objectWillChange.send()
    }
    
    private static func makeTitleConfig() -> CustomTextConfiguration {
        CustomTextConfiguration(
            title: "NEWS APP",
            titleColor: .orange,
            textType: .xlarge,
            isBold: true
        )
    }
    
    private static func makeEmailFieldConfig() -> CustomTextFieldConfiguration {
        CustomTextFieldConfiguration(
            title: "Email",
            placeholder: "Enter Email",
            isSecure: false,
            validationType: .email
        )
    }
    
    private static func makePasswordFieldConfig() -> CustomTextFieldConfiguration {
        CustomTextFieldConfiguration(
            title: "Password",
            placeholder: "Enter Password",
            isSecure: true,
            validationType: .password
        )
    }
    
    private static func makeLoginButtonConfig() -> CustomButtonConfiguration {
        CustomButtonConfiguration(
            title: "Login",
            backgroundColor: .orange,
            isDisabled: true,
            isLoading: false,
            action: {}
        )
    }
    
    private static func makeDescConfig() -> CustomTextConfiguration {
        CustomTextConfiguration(
            title: "Don't have an account?",
            titleColor: .gray,
            textType: .large,
            isBold: false
        )
    }
    
    func login() {
        loginButton.config.isLoading = true
        loginUseCase.login(
            email: emailField.text,
            password: passwordField.text
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginButton.config.isLoading = false
                switch result {
                case .success:
                    self?.isLoginSuccess = true
                case .failure:
                    self?.isLoginSuccess = false
                }
                self?.objectWillChange.send()
            }
        }
    }
}
