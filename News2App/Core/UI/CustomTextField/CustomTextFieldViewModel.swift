//
//  CustomTextFieldViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine

class CustomTextFieldViewModel: ObservableObject {
    @Published var text: String = "" {
        didSet {
            validate()
        }
    }
    @Published var errorMessage: String? = nil
    
    let config: CustomTextFieldConfiguration
    
    init(config: CustomTextFieldConfiguration) {
        self.config = config
    }
    
    var isValid: Bool {
        errorMessage == nil && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func validate() {
        switch config.validationType {
        case .email:
            if text.isEmpty {
                errorMessage = "Email tidak boleh kosong"
            } else if !Validation.isValidEmail(text) {
                errorMessage = "Email tidak valid "
            } else {
                errorMessage = nil
            }
        case .password:
            if !Validation.isValidPassword(text) {
                errorMessage = "Password must be 8+ characters, incl. uppercase, number, symbol"
            } else {
                errorMessage = nil
            }
        case .none:
            errorMessage = text.isEmpty ? "\(config.title) tidak boleh kosong" : nil
        }
    }
}
