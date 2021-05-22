//
// ScopedLoggers
// Robologs
//
// Created by Alex Babaev on 15 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

/// Logger that defines root scope for the application. It will be the same for all installations of the specific application version.
public class AppLogger: TracedLogger {
    public init(
        bundleId: String, version: String, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: Log.String] = [
            "bundleId": "\(safe: bundleId)",
            "version": "\(version)"
        ]
        super.init(tracer: .app, meta: meta, logger: logger, file: file, function: function, line: line)
    }
}

/// Logger defines installation scope of the app. ID will stay the same for the duration of app installation on a single device.
/// meta-properties of the scope include OS type/version.
public class InstallLogger: TracedLogger {
    public struct DeviceInfo {
        public enum OSInfo {
            case iOS(version: String)
            case iPadOS(version: String)
            case macOS(version: String)
            case watchOS(version: String)
            case tvOS(version: String)

            var string: String {
                switch self {
                    case .iOS(let version): return "iOS v.\(version)"
                    case .iPadOS(let version): return "iPadOS v.\(version)"
                    case .macOS(let version): return "macOS v.\(version)"
                    case .watchOS(let version): return "watchOS v.\(version)"
                    case .tvOS(let version): return "tvOS v.\(version)"
                }
            }
        }

        let osInfo: OSInfo

        public init(osInfo: OSInfo) {
            self.osInfo = osInfo
        }
    }

    private let keyInstallId: String = "__robologs.__internal.installId"

    public init(deviceInfo: DeviceInfo, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line) {
        let userDefaults = UserDefaults.standard
        let installId: String
        if let id = userDefaults.string(forKey: keyInstallId) {
            installId = id
        } else {
            installId = UUID().uuidString
            userDefaults.set(installId, forKey: keyInstallId)
        }

        let meta: [String: Log.String] = [
            "os": "\(deviceInfo.osInfo.string)"
        ]
        super.init(tracer: .install(id: installId), meta: meta, logger: logger, file: file, function: function, line: line)
    }
}

public class SessionLogger: TracedLogger {
    public init(
        userId: String, isGuest: Bool, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: Log.String] = [
            "userId": "\(userId)",
            "isGuest": "\(isGuest)",
        ]
        let tracer: Log.Tracer = .session(userId: userId, isGuest: isGuest)
        super.init(tracer: tracer, meta: meta, logger: logger, file: file, function: function, line: line)
    }
}
