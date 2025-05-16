//
//  AppDelegate.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupNotification()
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    fileprivate func setupNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
