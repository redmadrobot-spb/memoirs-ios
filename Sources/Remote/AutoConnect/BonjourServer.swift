//
// BonjourServer
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Darwin
import CommonCrypto
#if canImport(UIKit)
import UIKit
#endif

func sha256(string: String) -> String? {
    guard let data = string.data(using: .utf8) else { return nil }

    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).base64EncodedString()
}

public class BonjourServer: NSObject, NetServiceDelegate {
    private let netServiceType = "_robologs._tcp."
    private let netServiceDomain = "local."

    private let netServiceNamePrefix: String = "Robologs-"
    private var netService: NetService?
    private var logger: LabeledLogger!

    public init(logger: Logger) {
        super.init()

        self.logger = LabeledLogger(object: self, logger: logger)
        self.logger.debug("\(ProcessInfo.processInfo.environment)")
        self.logger.warning("Created. WARNING!!! This must be done only in debug mode")
    }

    private var deviceIdHash: String? {
        if #available(iOS 13.0, *) {
            let deviceUDID = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
            // TODO: Add fallback for manual udid setup
            if let deviceUDID = deviceUDID, let hash = sha256(string: deviceUDID) {
                self.logger.debug("Found device UDID: \(deviceUDID)")
                return hash
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    static let recordName = "name"
    static let recordEndpoint = "endpoint"
    static let recordSenderId = "senderId"
    static let recordIOSSimulator = "iOSSimulator"

    public func publish(endpoint: String, senderId: String) {
        if netService != nil {
            stopPublishing()
        }

        let serviceName = "\(netServiceNamePrefix)\(UUID().uuidString)"
        let netService = NetService(
            domain: netServiceDomain,
            type: netServiceType,
            name: serviceName,
            port: (Int32(48000) ..< 65536).randomElement() ?? 32128
        )
        netService.schedule(in: RunLoop.main, forMode: .common)
        netService.delegate = self
        self.netService = netService

        var txtRecord: [String: Data] = [:]
        if let data = senderId.data(using: String.Encoding.utf8) {
            txtRecord[BonjourServer.recordSenderId] = data
        }
        if let data = endpoint.data(using: String.Encoding.utf8) {
            txtRecord[BonjourServer.recordEndpoint] = data
        }
        #if canImport(UIKit)
        let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"].map { "Simulator: \($0)" } ?? UIDevice.current.name
        #else
        let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"].map { "Simulator: \($0)" } ?? "—"
        #endif
        if let data = deviceName.data(using: .utf8) {
            txtRecord[BonjourServer.recordName] = data
        }
        if let deviceIdHash = self.deviceIdHash, let data = deviceIdHash.data(using: .utf8) {
            txtRecord[BonjourServer.recordIOSSimulator] = data
        }
        guard !txtRecord.isEmpty else {
            self.logger.error("Can't publish empty txt record :(")
            return
        }

        let result = netService.setTXTRecord(NetService.data(fromTXTRecord: txtRecord))
        netService.publish(options: .listenForConnections)
        self.logger.debug("Published senderId: \(senderId) (result: \(result))")
    }

    public func stopPublishing() {
        guard let netService = netService else { return }

        netService.stop()
        netService.remove(from: RunLoop.main, forMode: .common)
        self.netService = nil
    }

    // MARK: - NetService Delegate

    public func netServiceWillPublish(_ sender: NetService) {
        self.logger.debug("")
    }

    public func netServiceDidPublish(_ sender: NetService) {
        self.logger.debug("")
    }

    public func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        self.logger.debug("\(errorDict)")
    }

    public func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        self.logger.debug("")
    }
}
