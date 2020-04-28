//
// BonjourClient
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Darwin
import CryptoKit

public class BonjourClient: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    public var serviceFound: ((_ sourceId: String) -> Void)?
    public var serviceDisappeared: ((_ sourceId: String) -> Void)?

    private let robologsServiceBrowser = NetServiceBrowser()
    private let rdLinkServiceBrowser = NetServiceBrowser()
    private var logger: LabeledLogger!

    private let typeRobologs = "_robologs._tcp."
    private let typeRemoteDebugLink = "_rdlink._tcp."

    public init(logger: Logger) {
        super.init()

        self.logger = LabeledLogger(object: self, logger: logger)

        robologsServiceBrowser.delegate = self
        robologsServiceBrowser.schedule(in: RunLoop.current, forMode: .common)
        robologsServiceBrowser.searchForServices(ofType: typeRobologs, inDomain: "local.")

        // This server is shown when Xcode debug session via USB is started
        rdLinkServiceBrowser.delegate = self
        rdLinkServiceBrowser.schedule(in: RunLoop.current, forMode: .common)
        rdLinkServiceBrowser.searchForServices(ofType: typeRemoteDebugLink, inDomain: "local.")

        // This is service that is shown in Bonjour when app is connected for WiFi debug
        // And we can't use it afaik because it is shown to everybody. Don't know if it is right
//        browser.searchForServices(ofType: "_apple-mobdev2._tcp.", inDomain: "local.")
        self.logger.debug("Started")
    }

    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        self.logger.debug("")
    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        self.logger.debug("")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        self.logger.debug("Error: \(errorDict)")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        self.logger.debug("")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        self.logger.debug("")
    }

    private var robologsResolvingServices: [NetService] = []
    private var remoteDebugLinkResolvingServices: [NetService] = []
    private var remoteDebugLinkAddresses: Set<String> = []

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        logger.verbose("Found: \(service.domain).\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                robologsResolvingServices.append(service)
                service.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    service.resolve(withTimeout: 2)
                }
//                tryToConnect(to: service)
            case typeRemoteDebugLink:
                remoteDebugLinkResolvingServices.append(service)
                service.delegate = self
                service.resolve(withTimeout: 2)
//                addRemoteDebugLinkAddresses(from: service)
            default:
                break
        }
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        logger.verbose("Disappeared: \(service.domain).\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                disconnect(from: service)
            case typeRemoteDebugLink:
                removeRemoteDebugLinkAddresses(from: service)
            default:
                break
        }
    }

    private func addRemoteDebugLinkAddresses(from service: NetService) {
        let addresses = resolveOnlyIPv4(addresses: service.addresses ?? [])
        remoteDebugLinkAddresses.formUnion(addresses)
        logger.debug("Found Remote Debug Links with addresses: \(addresses)")
    }

    private func removeRemoteDebugLinkAddresses(from service: NetService) {
        let addresses = resolveOnlyIPv4(addresses: service.addresses ?? [])
        remoteDebugLinkAddresses.subtract(addresses)
        logger.debug("Removed Remote Debug Link addresses: \(addresses)")
    }

    private func tryToConnect(to service: NetService) {
        let addresses = resolveOnlyIPv4(addresses: service.addresses ?? [])
        guard
            !addresses.isEmpty,
            let txtRecord = service.txtRecordData().map({ NetService.dictionary(fromTXTRecord: $0) }),
            isRobologsServiceLocal(addresses: addresses, txtRecord: txtRecord)
        else {
            logger.warning("Can't connect to \(service.domain).\(service.type)/\(service.name)")
            return
        }

        if let senderIdData = txtRecord["senderId"], let senderId = String(data: senderIdData, encoding: .utf8) {
            logger.warning("Robologs service appeared with senderId: \(senderId)")
            serviceFound?(senderId)
        }
    }

    private func disconnect(from service: NetService) {
        guard
            let txtRecord = service.txtRecordData().map({ NetService.dictionary(fromTXTRecord: $0) })
        else {
            logger.warning("Can't disconnect from \(service.domain).\(service.type)/\(service.name)")
            return
        }

        if let senderIdData = txtRecord["senderId"], let senderId = String(data: senderIdData, encoding: .utf8) {
            logger.warning("Robologs service disappeared with senderId: \(senderId)")
            serviceDisappeared?(senderId)
        }
    }

    // MARK: - NetService Delegate

    public func netServiceDidResolveAddress(_ service: NetService) {
        logger.debug("Found: \(service.domain).\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                tryToConnect(to: service)
                robologsResolvingServices = robologsResolvingServices.filter { $0 !== service }
            case typeRemoteDebugLink:
                addRemoteDebugLinkAddresses(from: service)
                remoteDebugLinkResolvingServices = remoteDebugLinkResolvingServices.filter { $0 !== service }
            default:
                break
        }
    }

    public func netService(_ service: NetService, didNotResolve errorDict: [String: NSNumber]) {
        logger.debug("Error: \(errorDict)")
        robologsResolvingServices = robologsResolvingServices.filter { $0 !== service }
        remoteDebugLinkResolvingServices = remoteDebugLinkResolvingServices.filter { $0 !== service }
    }

    // MARK: - Helper Methods

    private func isRobologsServiceLocal(addresses: [String], txtRecord: [String: Data]) -> Bool {
        guard !addresses.contains(where: { remoteDebugLinkAddresses.contains($0) }) else {
            logger.debug("Robologs service address is in Remote Debug Link addresses. Good!")
            return true
        }

        if #available(iOS 13.0, *) {
            guard let deviceIdData = txtRecord["deviceId"], let deviceId = String(data: deviceIdData, encoding: .utf8) else {
                logger.debug("No deviceID in TXT records")
                return false
            }

            let hashedUDIDs: [String] = Shell
                .CommandLine(in: Shell.userHomeDirectory, command: "instruments -s devices", logger: logger.logger)
                .execute()
                .components(separatedBy: "\n")
                .filter { $0 != "Known Devices:" && !$0.isEmpty }
                .compactMap { string in
                    guard let left = string.firstIndex(of: "["), let right = string.firstIndex(of: "]") else { return nil }

                    logger.verbose("  Found device UDID: \(string[left ..< right])")
                    return string[left ..< right].data(using: .utf8)
                }
                .map { (udidData: Data) in SHA256.hash(data: udidData).description }

            let isLocalUDID = hashedUDIDs.contains(deviceId)
            logger.debug(
                isLocalUDID ? "> deviceId from TXT (\(deviceId)) is in local UDIDs. Good!" : "> deviceId from TXT not found in local UDIDs"
            )
            return isLocalUDID
        } else {
            return false
        }
    }

    private func resolveOnlyIPv4(addresses: [Data]) -> [String] {
        addresses.compactMap { address in
            let data = address as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)

            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                }

                return String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii)
            } else {
                return nil
            }
        }
    }
}
