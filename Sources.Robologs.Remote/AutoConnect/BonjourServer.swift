//
// BonjourServer
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs
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
    private var logger: Logger!

    public let generatedPort: Int32 = (Int32(48000) ..< 65536).randomElement() ?? 32128

    public init(logger: Loggable) {
        super.init()

        self.logger = Logger(object: self, logger: logger)
        self.logger.debug("\(ProcessInfo.processInfo.environment)")
        self.logger.warning("Created. WARNING!!! This must be done only in debug mode")
    }

    private var deviceIdHash: String? {
        if #available(iOS 13.0, *) {
            let deviceUDID = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
            // TODO: Add fallback for manual udid setup
            if let deviceUDID = deviceUDID, let hash = sha256(string: deviceUDID) {
                logger.debug("Found device UDID: \(deviceUDID)")
                return hash
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    static let recordName: String = "name"
    static let recordEndpoint: String = "endpoint"
    static let recordSenderId: String = "senderId"
    static let recordIOSSimulator: String = "iOSSimulator"
    static let recordAndroidId: String = "androidId"
    static let recordLocalServerPort: String = "localServerPort"

    public func publish(senderId: String, remoteEndpoint: String?, localPort: Int32?) {
        if netService != nil {
            stopPublishing()
        }

        let serviceName = "\(netServiceNamePrefix)\(UUID().uuidString)"
        let netService = NetService(
            domain: netServiceDomain,
            type: netServiceType,
            name: serviceName,
            port: generatedPort
        )
        netService.schedule(in: RunLoop.main, forMode: .common)
        netService.delegate = self
        self.netService = netService

        var txtRecord: [String: String] = [:]
        txtRecord[BonjourServer.recordSenderId] = senderId

        if let remoteEndpoint = remoteEndpoint {
            txtRecord[BonjourServer.recordEndpoint] = remoteEndpoint
        }
        txtRecord[BonjourServer.recordLocalServerPort] = localPort.map { "\($0)" }

        #if canImport(UIKit)
        let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"].map { "Simulator: \($0)" } ?? UIDevice.current.name
        #else
        let deviceName = (Bundle.main.infoDictionary?["CFBundleName"] as? String).map { "Bundle Name: \($0)" } ?? "—"
        #endif
        txtRecord[BonjourServer.recordName] = deviceName
        if let deviceIdHash = deviceIdHash {
            txtRecord[BonjourServer.recordIOSSimulator] = deviceIdHash
        }
        guard !txtRecord.isEmpty else {
            logger.error("Can't publish empty txt record :(")
            return
        }

        let result = netService.setTXTRecord(NetService.data(fromTXTRecord: txtRecord.compactMapValues { $0.data(using: .utf8) }))
        netService.publish(options: .listenForConnections)
        logger.debug("Published to bonjour (\(result ? "success" : "fail")): \(txtRecord)")
    }

    public func stopPublishing() {
        guard let netService = netService else { return }

        netService.stop()
        netService.remove(from: RunLoop.main, forMode: .common)
        self.netService = nil
    }

    // MARK: - NetService Delegate

    public func netServiceWillPublish(_ sender: NetService) {
        logger.debug("")
    }

    public func netServiceDidPublish(_ sender: NetService) {
        logger.debug("")
    }

    public func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        logger.debug("\(errorDict)")
    }

    public func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        logger.debug("")
    }
}
