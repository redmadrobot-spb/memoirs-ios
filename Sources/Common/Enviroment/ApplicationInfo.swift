//
// ApplicationInfo
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

public protocol ApplicationInfo {
    var appId: String { get }
    var appName: String? { get }
    var appVersion: String? { get }
    var appBuild: String? { get }
    var operationSystem: String? { get }
    var operationSystemVersion: String? { get }
    var deviceModel: String? { get }

    var deviceId: String { get }
}
