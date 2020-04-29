//
// BonjourServer
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import CryptoKit

public class BonjourServer: NSObject, NetServiceDelegate {
    private let netService: NetService
    private var logger: LabeledLogger!

    private let randomizedName: String = "Robologs-\(UUID().uuidString)"

    public init(logger: Logger) {
        let type = "_robologs._tcp."

        netService = NetService(domain: "local.", type: type, name: randomizedName, port: (Int32(48000) ..< 65536).randomElement() ?? 32128)
        super.init()

        netService.schedule(in: RunLoop.current, forMode: .common)
        netService.delegate = self

        self.logger = LabeledLogger(object: self, logger: logger)
        self.logger.debug("\(ProcessInfo.processInfo.environment)")
        self.logger.warning("Created. WARNING!!! This must be done only in debug mode")
    }

    private var deviceIdHash: String? {
        if #available(iOS 13.0, *) {
            let deviceUDID = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
            // TODO: Add fallback for manual udid setup
            if let deviceUDID = deviceUDID, let udidData = deviceUDID.data(using: .utf8) {
                self.logger.debug("Found device UDID: \(deviceUDID)")
                let hash = SHA256.hash(data: udidData)
                return hash.description
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    public func publish(senderId: String) {
        var txtRecord: [String: Data] = [:]
        if let deviceIdHash = self.deviceIdHash, let data = deviceIdHash.data(using: .utf8) {
            txtRecord["deviceId"] = data
        }
        if let data = senderId.data(using: String.Encoding.utf8) {
            txtRecord["senderId"] = data
        }
        guard !txtRecord.isEmpty else {
            self.logger.error("Can't publish empty txt record :(")
            return
        }

        let result = netService.setTXTRecord(NetService.data(fromTXTRecord: txtRecord))
        netService.publish(options: .listenForConnections)
        self.logger.debug("Published senderId: \(senderId) (result: \(result))")
    }

    public func publish(liveId: String) {
        guard let txtRecord: [String: Data] = liveId.data(using: String.Encoding.utf8).map({ [ "liveID": $0 ] }) else {
            self.logger.error("Can't publish senderId as txt record")
            return
        }

        let result = netService.setTXTRecord(NetService.data(fromTXTRecord: txtRecord))
        netService.publish(options: .listenForConnections)
        self.logger.debug("Published liveId: \(liveId) (result: \(result))")
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
