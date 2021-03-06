//
// DefaultMemoirs
// Memoirs
//
// Created by Alex Babaev on 15 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Memoir that defines root scope for the application. It will be the same for all installations of the specific application version.
public class AppMemoir: TracedMemoir {
    public init(
        bundleId: String? = nil, version: String? = nil,
        memoir: Memoir,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: SafeString]
        let foundBundleId: String
        if let bundleId = bundleId, let version = version {
            foundBundleId = bundleId
            meta = [
                "bundleId": "\(safe: bundleId)",
                "version": "\(version)"
            ]
        } else if let infoPlist = Bundle.main.infoDictionary, let bundleId = infoPlist["CFBundleIdentifier"] as? String,
               let version = infoPlist["CFBundleShortVersionString"] as? String, let build = infoPlist["CFBundleVersion"] as? String {
            foundBundleId = bundleId
            meta = [
                "bundleId": "\(safe: bundleId)",
                "version": "\(version):\(build)"
            ]
        } else {
            fatalError("Please specify bundleId and version. Automatic bundleId and version detection works only if Info.plist is present")
        }

        super.init(tracer: .app(id: foundBundleId), meta: meta, memoir: memoir, file: file, function: function, line: line)
    }
}

/// Memoir defines installation instance scope of the app. ID will stay the same for the duration of app installation on a single device.
/// meta-properties of the scope include OS type/version.
public class InstanceMemoir: TracedMemoir {
    public struct DeviceInfo {
        public enum OSInfo {
            case iOS(version: String)
            case catalyst(version: String)
            case macOS(version: String)
            case watchOS(version: String)
            case tvOS(version: String)

            var string: String {
                switch self {
                    case .iOS(let version): return "iOS v.\(version)"
                    case .catalyst(let version): return "macOS/Catalyst v.\(version)"
                    case .macOS(let version): return "macOS v.\(version)"
                    case .watchOS(let version): return "watchOS v.\(version)"
                    case .tvOS(let version): return "tvOS v.\(version)"
                }
            }

            public static var detected: OSInfo {
                let version = ProcessInfo.processInfo.operatingSystemVersionString

                #if os(tvOS)
                return .tvOS(version: version)
                #elseif os(iOS)
                #if targetEnvironment(macCatalyst)
                return .catalyst(version: version)
                #else
                return .iOS(version: version)
                #endif
                #elseif os(watchOS)
                return .watchOS(version: version)
                #elseif os(macOS)
                return .macOS(version: version)
                #else
                fatalError("Can't detect OS")
                #endif
            }
        }

        let osInfo: OSInfo
        // TODO: Add Device Info

        public init(osInfo: OSInfo) {
            self.osInfo = osInfo
        }
    }

    private static let keyInstanceId: String = "__memoirs.__internal.instanceId"
    public static var defaultInstanceId: String {
        let userDefaults = UserDefaults.standard
        if let id = userDefaults.string(forKey: keyInstanceId) {
            return id
        } else {
            let instanceId = UUID().uuidString
            userDefaults.set(instanceId, forKey: keyInstanceId)
            return instanceId
        }
    }

    public private(set) var instanceId: String

    public init(
        deviceInfo: DeviceInfo = .init(osInfo: .detected), instanceId: String = InstanceMemoir.defaultInstanceId, memoir: Memoir,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        self.instanceId = instanceId
        let meta: [String: SafeString] = [
            "os": "\(deviceInfo.osInfo.string)"
        ]
        super.init(tracer: .instance(id: instanceId), meta: meta, memoir: memoir, file: file, function: function, line: line)
    }
}

public class SessionMemoir: TracedMemoir {
    public init(
        userId: String, isGuest: Bool, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        let meta: [String: SafeString] = [
            "userId": "\(userId)",
            "isGuest": "\(isGuest)",
        ]
        let tracer: Tracer = .session(userId: "\(isGuest ? "guest." : "")\(userId)")
        super.init(tracer: tracer, meta: meta, memoir: memoir, file: file, function: function, line: line)
    }

    public func updateSessionId(userId: String, isGuest: Bool) {
        updateTracer(to: .session(userId: "\(isGuest ? "guest." : "")\(userId)"))
    }
}
