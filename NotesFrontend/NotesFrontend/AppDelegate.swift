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

        let processor = RequestProcessor<User>()
        let service = AutorisationService(requestProcessor: processor)
        let presenter = AutorisationPresenter(autorisationService: service)
        let rootVC = AutorisationViewController(presenter: presenter)

        let window = UIWindow()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}
