//
//  AppDelegate.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let rootVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: rootVC)

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}
