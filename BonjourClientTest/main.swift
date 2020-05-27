//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

let androidHome = ProcessInfo.processInfo.environment["ANDROID_HOME"]
if androidHome == nil {
    print("Set up ANDROID_HOME environment variable to Android SDK root be able to listen for Android devices automatically")
}

let client = BonjourClient(adbRunDirectory: androidHome.map { "\($0)/platform-tools" }, logger: PrintLogger(onlyTime: true))
let subscription = client.subscribeOnSDKsListUpdate { list in
    print("\nFound!\n\(list)\n")
}

RunLoop.main.run()
