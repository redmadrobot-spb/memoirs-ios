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
    public var serviceFound: ((_ sourceId: String, _ deviceName: String) -> Void)?
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

    private var foundServiceNamesBySourceId: [String: String] = [:]
    private var subscriptions: [String: ([(sourceId: String, deviceName: String)]) -> Void] = [:]

    public func subscribeOnSDKsListUpdate(listener: @escaping ([(sourceId: String, deviceName: String)]) -> Void) -> Subscription {
        let id = UUID().uuidString
        subscriptions[id] = listener
        listener(foundServiceNamesBySourceId.map { ($0, $1) })
        return Subscription {
            self.subscriptions[id] = nil
        }
    }

    private func notify() {
        subscriptions.values.forEach { $0(foundServiceNamesBySourceId.map { ($0, $1) }) }
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
        logger.verbose("Found: \(service.domain)/\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                robologsResolvingServices.append(service)
                service.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    service.resolve(withTimeout: 5)
                }
            case typeRemoteDebugLink:
                remoteDebugLinkResolvingServices.append(service)
                service.delegate = self
                service.resolve(withTimeout: 5)
            default:
                break
        }
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        logger.verbose("Disappeared: \(service.domain)/\(service.type)/\(service.name) (moreComing: \(moreComing))")
        switch service.type {
            case typeRobologs:
                service.delegate = nil
                disconnect(from: service)
                robologsResolvingServices = robologsResolvingServices.filter { $0 !== service }
            case typeRemoteDebugLink:
                service.delegate = nil
                removeRemoteDebugLinkAddresses(from: service)
                remoteDebugLinkResolvingServices = remoteDebugLinkResolvingServices.filter { $0 !== service }
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

    private var localRobologSDKs: [String: String] = [:]
    private var foundRobologSDKs: [String: String] = [:]

    private func tryToConnect(to service: NetService) {
        guard let txtRecord = service.txtRecordData().map({ NetService.dictionary(fromTXTRecord: $0) }) else {
            logger.warning("Can't connect to \(service.domain)/\(service.type)/\(service.name)")
            return
        }
        guard let senderIdData = txtRecord["senderId"], let senderId = String(data: senderIdData, encoding: .utf8) else {
            logger.warning("Service does not have senderId info: \(service.domain)/\(service.type)/\(service.name)")
            return
        }

        let deviceName = txtRecord["deviceName"].map { String(data: $0, encoding: .utf8) ?? "—" } ?? "—"
        foundRobologSDKs[service.name] = senderId
        foundServiceNamesBySourceId[senderId] = deviceName
        notify()

        let addresses = resolveOnlyIPv4(addresses: service.addresses ?? [])
        if isRobologsServiceLocal(addresses: addresses, txtRecord: txtRecord) {
            if let senderIdData = txtRecord["senderId"], let senderId = String(data: senderIdData, encoding: .utf8) {
                localRobologSDKs[service.name] = senderId
                serviceFound?(senderId, deviceName)
                logger.debug("Robologs service appeared with senderId: \(senderId)")
            }
        } else {
            logger.debug("Not local service: \(service.domain)/\(service.type)/\(service.name)")
        }
    }

    private func disconnect(from service: NetService) {
        guard let senderId = foundRobologSDKs[service.name] else { return }

        foundServiceNamesBySourceId[senderId] = nil
        notify()

        foundRobologSDKs[service.name] = nil
        localRobologSDKs[service.name] = nil
        logger.debug("Robologs service disappeared with senderId: \(senderId)")
        serviceDisappeared?(senderId)
    }

    // MARK: - NetService Delegate

    public func netServiceDidResolveAddress(_ service: NetService) {
        logger.debug("Found: \(service.domain)/\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                tryToConnect(to: service)
            case typeRemoteDebugLink:
                addRemoteDebugLinkAddresses(from: service)
            default:
                break
        }
    }

    public func netServiceDidStop(_ sender: NetService) {

    }

    public func netService(_ service: NetService, didNotResolve errorDict: [String: NSNumber]) {
        logger.debug("Error: \(errorDict)")
    }

    // MARK: - Helper Methods

    private func isRobologsServiceLocal(addresses: [String], txtRecord: [String: Data]) -> Bool {
        guard !addresses.contains(where: { remoteDebugLinkAddresses.contains($0) }) else {
            logger.debug("Robologs service address is in Remote Debug Link addresses. Good!")
            return true
        }
        guard let deviceIdData = txtRecord["deviceId"], let deviceId = String(data: deviceIdData, encoding: .utf8) else {
            logger.debug("No deviceID in TXT records")
            return false
        }

        if #available(iOS 13.0, *) {
            let hashedUDIDs: [String] = Shell
                .CommandLine(in: Shell.userHomeDirectory, command: "instruments -s devices", logger: logger.logger)
                .execute()
                .components(separatedBy: "\n")
                .filter { $0 != "Known Devices:" && !$0.isEmpty }
                .compactMap { string in
                    guard let left = string.firstIndex(of: "["), let right = string.firstIndex(of: "]") else { return nil }

                    let udid = string[left ..< right].dropFirst()
                    logger.verbose("  Found device UDID: \"\(udid)\"")
                    return udid.data(using: .utf8)
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

                var address = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii)
                if address == "127.0.0.1" {
                    address = nil
                }
                return address
            } else {
                return nil
            }
        }
    }
}
