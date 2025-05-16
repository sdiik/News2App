//
//  LoginView.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            formSection
            loginButtonSection
            registerSection
        }
        .padding(.horizontal)
        .onChange(of: viewModel.isLoginSuccess) { success in
            print("Login success: \(success)")
            if success {
                coordinator.navigate(to: .home)
                viewModel.isLoginSuccess = false
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack {
            Image("icon_news")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            CustomTextView(viewModel: viewModel.title)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 8) {
            CustomTextField(viewModel: viewModel.emailField)
            CustomTextField(viewModel: viewModel.passwordField)
        }
    }
    
    private var loginButtonSection: some View {
        CustomButtonView(viewModel: viewModel.loginButton)
    }
    
    private var registerSection: some View {
        HStack {
            CustomTextView(viewModel: viewModel.description)
            Button(action: {
                coordinator.navigate(to: .register)
            }) {
                Text("Register")
                    .foregroundColor(.orange)
                    .bold()
            }
        }
        .padding(.top, 8)
    }
}
