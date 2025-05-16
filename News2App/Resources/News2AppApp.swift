//
//  News2AppApp.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

@main
struct News2AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appCoordinator = AppCoordinator()
    @StateObject var loadingManager = LoadingManager()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(appCoordinator)
                .environmentObject(loadingManager)
        }
    }
}
