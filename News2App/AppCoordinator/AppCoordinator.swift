//
//  AppCoordinator.swift
//  News2App
//
//  Created by ahmad shiddiq on 01/05/25.
//

import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var path: [Route] = []
    @Published var isLoggedIn: Bool = false
    
    let credentialsStorage = CredentialsStorage()
    private var cancellables: Set<AnyCancellable> = []

    enum Route: Hashable {
        case login
        case register
        case home
        case detail(id: Int, detailType: DetailType)
    }
    
    init() {
        print("AppCoordinator initialized")
        startTokenMonitor()
    }
    
    func checkLoginStatus() {
        if credentialsStorage.isExpired() {
            handleLogout()
        } else {
            self.isLoggedIn = true
            path = [.home]
        }
    }
    
    func checkExpired() {
        if credentialsStorage.isExpired() {
            handleLogout()
        }
    }
    
    private func handleLogout() {
        credentialsStorage.clear()
        isLoggedIn = false
        path = [.login]
    }
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func goBack() {
        _ = path.popLast()
    }
    
    func reset() {
        path = []
    }
    
    private func startTokenMonitor() {
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.credentialsStorage.isExpired(), self.isLoggedIn {
                    self.handleLogout()
                }
            }
            .store(in: &cancellables)
    }
   
}
