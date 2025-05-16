//
//  RegisterView.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            formSection
            registerButtonSection
            loginSection
        }
        .padding(.horizontal)
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image("icon_news")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            Text("Register").font(.system(size: 18, weight: .semibold, design: .default))
            Text("Create your account to get the latest updates and features").font(.system(size: 16, weight: .regular)).multilineTextAlignment(.center)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 8) {
            CustomTextField(viewModel: viewModel.emailField)
            CustomTextField(viewModel: viewModel.passwordField)
        }
    }
    
    private var registerButtonSection: some View {
        CustomButtonView(viewModel: viewModel.registerButton)
    }
    
    private var loginSection: some View {
        HStack {
            Text("Already have an account ?")
                .foregroundColor(.gray)
            Text("Login")
                .foregroundColor(.orange)
                .onTapGesture {
                    coordinator.goBack()
            }
        }
    }
}
