//
// ApplicationInfo
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

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

private let standardDeviceIdKey: String = "robologs.uiKitApplicationInfo.deviceId"
private var standardDeviceId: String {
    let deviceId = UserDefaults.standard.string(forKey: standardDeviceIdKey)
    if let deviceId = deviceId {
        return deviceId
    } else {
        #if canImport(UIKit)
        let vendorOrGeneratedId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #elseif canImport(AppKit)
        let vendorOrGeneratedId = UUID().uuidString
        #endif
        UserDefaults.standard.set(vendorOrGeneratedId, forKey: standardDeviceIdKey)
        return vendorOrGeneratedId
    }
}

#if canImport(UIKit)
public struct UIKitApplicationInfo: ApplicationInfo {
    public let appId: String
    public let appName: String?
    public let appVersion: String?
    public let appBuild: String?
    public let operationSystem: String?
    public let operationSystemVersion: String?
    public let deviceModel: String?

    public var deviceId: String = standardDeviceId

    public static var current: UIKitApplicationInfo {
        guard
            let infoPlist = Bundle.main.infoDictionary,
            let appId = infoPlist["CFBundleIdentifier"] as? String
        else { fatalError("Can't load ios application environment") }

        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine)
            .children
            .reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }

                return identifier + String(UnicodeScalar(UInt8(value)))
            }

        return UIKitApplicationInfo(
            appId: appId,
            appName: infoPlist["CFBundleName"] as? String,
            appVersion: infoPlist["CFBundleShortVersionString"] as? String,
            appBuild: infoPlist["CFBundleVersion"] as? String,
            operationSystem: UIDevice.current.systemName,
            operationSystemVersion: UIDevice.current.systemVersion,
            deviceModel: identifier
        )
    }
}
#elseif canImport(AppKit)
public struct AppKitApplicationInfo: ApplicationInfo {
    public let appId: String
    public let appName: String?
    public let appVersion: String?
    public let appBuild: String?
    public let operationSystem: String?
    public let operationSystemVersion: String?
    public let deviceModel: String?

    public var deviceId: String = standardDeviceId

    public static var current: AppKitApplicationInfo {
        guard
            let infoPlist = Bundle.main.infoDictionary,
            let appId = infoPlist["CFBundleIdentifier"] as? String
        else { fatalError("Can't load ios application environment") }

        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine)
            .children
            .reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }

                return identifier + String(UnicodeScalar(UInt8(value)))
            }

        return AppKitApplicationInfo(
            appId: appId,
            appName: infoPlist["CFBundleName"] as? String,
            appVersion: infoPlist["CFBundleShortVersionString"] as? String,
            appBuild: infoPlist["CFBundleVersion"] as? String,
            operationSystem: "macOS",
            operationSystemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            deviceModel: identifier
        )
    }
}
#endif
