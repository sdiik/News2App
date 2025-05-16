//
//  CustomTextField.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct CustomTextField: View {
    @ObservedObject var viewModel: CustomTextFieldViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.config.title)
                .font(.caption)
                .foregroundColor(.gray)
            Group {
                if viewModel.config.isSecure {
                    SecureField(viewModel.config.placeholder, text: $viewModel.text)
                } else {
                    TextField(viewModel.config.placeholder, text: $viewModel.text)
                        .keyboardType(viewModel.config.validationType == .email ? .emailAddress : .default)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.errorMessage != nil ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
            )
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
        .animation(.easeInOut, value: viewModel.errorMessage)
    }
}
