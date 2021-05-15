//
// ScopedLoggers
// sdk-apple
//
// Created by Alex Babaev on 15 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

public protocol SingleScopeLogger: Loggable {
    var scope: Scope { get }
}

/// Logger that defines root scope for the application. It will be the same for all installations of the specific application version.
public class AppLogger: ScopedLogger, SingleScopeLogger {
    public let scope: Scope

    public init(bundleId: String, version: String, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line) {
        let meta: [String: LogString] = [
            "bundleId": "\(safe: bundleId)",
            "version": "\(version)"
        ]
        scope = Scope(.app, meta: meta)
        super.init(scopes: [ scope ], logger: logger, file: file, function: function, line: line)
    }
}

/// Logger defines installation scope of the app. ID will stay the same for the duration of app installation on a single device.
/// meta-properties of the scope include OS type/version.
public class InstallLogger: ScopedLogger, SingleScopeLogger {
    public struct DeviceInfo {
        public enum OS {
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

        let os: OS

        public init(os: OS) {
            self.os = os
        }
    }

    public let scope: Scope

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

        let meta: [String: LogString] = [
            "os": "\(deviceInfo.os.string)"
        ]
        scope = Scope(.install(id: installId), parent: .app, meta: meta)
        super.init(scopes: [ scope ], logger: logger, file: file, function: function, line: line)
    }
}

public class SessionLogger: ScopedLogger, SingleScopeLogger {
    public let scope: Scope

    public init(userId: String, isGuest: Bool, logger: InstallLogger, file: String = #file, function: String = #function, line: UInt = #line) {
        var meta: [String: LogString] = [:]
        meta["userId"] = "\(userId)"
        meta["isGuest"] = "\(isGuest)"
        scope = Scope(.session(userId: userId, isGuest: isGuest), parentName: logger.scope.name, meta: meta)
        super.init(scopes: [ scope ], logger: logger, file: file, function: function, line: line)
    }
}

public class ScopeLogger: ScopedLogger, SingleScopeLogger {
    public let scope: Scope

    public init(
        name: String, meta: [String: LogString] = [:], logger: SingleScopeLogger,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        scope = Scope(name: name, parentName: logger.scope.name, meta: meta)
        super.init(scopes: [ scope ], logger: logger, file: file, function: function, line: line)
    }
}
