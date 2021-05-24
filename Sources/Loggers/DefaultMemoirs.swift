//
// ScopedMemoirs
// Robologs
//
// Created by Alex Babaev on 15 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

/// Memoir that defines root scope for the application. It will be the same for all installations of the specific application version.
public class AppMemoir: TracedMemoir {
    public init(
        bundleId: String, version: String, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: SafeString] = [
            "bundleId": "\(safe: bundleId)",
            "version": "\(version)"
        ]
        super.init(tracer: .app(id: bundleId), meta: meta, memoir: memoir, file: file, function: function, line: line)
    }
}

/// Memoir defines installation instance scope of the app. ID will stay the same for the duration of app installation on a single device.
/// meta-properties of the scope include OS type/version.
public class InstanceMemoir: TracedMemoir {
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

    public init(deviceInfo: DeviceInfo, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line) {
        let userDefaults = UserDefaults.standard
        let installId: String
        if let id = userDefaults.string(forKey: keyInstallId) {
            installId = id
        } else {
            installId = UUID().uuidString
            userDefaults.set(installId, forKey: keyInstallId)
        }

        let meta: [String: SafeString] = [
            "os": "\(deviceInfo.osInfo.string)"
        ]
        super.init(tracer: .instance(id: installId), meta: meta, memoir: memoir, file: file, function: function, line: line)
    }
}

public class SessionMemoir: TracedMemoir {
    public init(
        userId: String, isGuest: Bool, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: SafeString] = [
            "userId": "\(userId)",
            "isGuest": "\(isGuest)",
        ]
        let tracer: Tracer = .session(userId: "\(isGuest ? "guest." : "")\(userId)")
        super.init(tracer: tracer, meta: meta, memoir: memoir, file: file, function: function, line: line)
    }
}
