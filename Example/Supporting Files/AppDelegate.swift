//
//  AppDelegate.swift
//  Example
//
//  Created by Roman Mazeev on 27.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        #if DEBUG
        LogString.isSensitive = false
        #else
        LogString.isSensitive = true
        #endif

        return true
    }
}
