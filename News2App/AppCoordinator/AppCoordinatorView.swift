//
//  AppCoordinatorView.swift
//  News2App
//
//  Created by ahmad shiddiq on 01/05/25.
//

import SwiftUI

struct AppCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack {
                Text("Welcome to News2App!")
                    .onAppear {
                        coordinator.checkLoginStatus()
                    }
            }
            .navigationDestination(for: AppCoordinator.Route.self) { route in
                switch route {
                case .login:
                    LoginView(viewModel: LoginViewModel())
                case .register:
                    RegisterView(viewModel: RegisterViewModel())
                case .home:
                    HomeView(viewModel: HomeViewModel())
                case .detail:
                    DetailView(viewModel: DetailViewModel(id: 30807, detailType: .articles))
                }
            }
        }
    }
}
