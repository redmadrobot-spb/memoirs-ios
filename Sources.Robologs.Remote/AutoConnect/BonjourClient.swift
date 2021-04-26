//
// BonjourClient
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs
import Darwin

public struct RobologsRemoteSDK {
    public var name: String
    public var id: String
    public var apiEndpoint: URL
    public var isLocalBroadcast: Bool

    public init(name: String, id: String, apiEndpoint: URL, isLocalBroadcast: Bool) {
        self.name = name
        self.id = id
        self.apiEndpoint = apiEndpoint
        self.isLocalBroadcast = isLocalBroadcast
    }
}

public class BonjourClient: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    public var serviceFound: ((RobologsRemoteSDK) -> Void)?
    public var serviceDisappeared: ((RobologsRemoteSDK) -> Void)?

    private let robologsServiceBrowser = NetServiceBrowser()
    private let rdLinkServiceBrowser = NetServiceBrowser()
    private var logger: LabeledLogger!

    private let typeRobologs = "_robologs._tcp."
    private let typeRemoteDebugLink = "_rdlink._tcp."

    private let workingQueue: DispatchQueue = DispatchQueue(label: "BonjourClient")
    private let completionQueue: DispatchQueue = DispatchQueue.main

    private var adbTimer: Timer!
    private let adbDirectoryUrl: URL?

    public init(adbRunDirectory: String?, logger: Logger) {
        adbDirectoryUrl = adbRunDirectory.flatMap { path in
            FileManager.default.fileExists(atPath: path) ? URL(fileURLWithPath: path) : nil
        }
        super.init()

        adbTimer = Timer(timeInterval: 5, target: self, selector: #selector(adbTimerFired), userInfo: nil, repeats: true)
        self.logger = LabeledLogger(object: self, logger: InfoGatheringLogger(meta: [:], logger: logger))

        start()
    }

    private func start() {
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
        logger.debug("Started")

        RunLoop.current.add(adbTimer, forMode: .common)
    }

    // MARK: - ADB Android Device Monitoring

    private var needCheckAdb: Bool = false

    @objc
    private func adbTimerFired(_ timer: Timer) {
        guard needCheckAdb else { return }

        workingQueue.async {
            self.needCheckAdb = false
            self.collectAdbRobologIds()
        }
    }

    private func collectAdbRobologIds() {
        let queue = DispatchQueue(label: "adbCollectingData")

        adbDevices { serialIds in
            let group = DispatchGroup()
            var connectedRobologIds: Set<String> = []
            for serialId in serialIds {
                group.enter()
                let devices = self.adbLogCat(for: serialId)
                queue.async {
                    connectedRobologIds.formUnion(devices)
                    group.leave()
                }
            }
            group.wait()

            queue.async {
                if self.androidADBConnectedIds != Set(connectedRobologIds) {
                    self.androidADBConnectedIds = Set(connectedRobologIds)
                    self.logger.verbose("Found robologIds in adb: \(self.androidADBConnectedIds)")
                    self.androidADBConnectedIds.forEach { self.foundAndroidLocalDevice(id: $0) }
                }
            }
        }
    }

    private func adbDevices(completion: @escaping (_ deviceSerialIds: [String]) -> Void) {
        guard let adbDirectoryUrl = adbDirectoryUrl else {
            logger.warning("ADB Monitoring was not started, directory for ADB is not specified")
            return
        }

        let command = Shell.ZSHCommandLine(command: "./adb devices", directory: adbDirectoryUrl, logger: logger)
        command.execute { _, _, output, _ in
            let serialIds: [String] = output
                .components(separatedBy: "\n")
                .filter { $0 != "List of devices attached" && !$0.isEmpty }
                .compactMap { $0.components(separatedBy: CharacterSet(charactersIn: " \t")).first { !$0.isEmpty } }
            completion(serialIds)
        }
    }

    private func adbLogCat(for serialId: String) -> [String] {
        logger.verbose("Looking robolog connection ids in adb for device \(serialId)")

        guard let adbDirectoryUrl = adbDirectoryUrl else {
            logger.warning("ADB Monitoring was not started, directory for ADB is not specified")
            return []
        }

        #if !targetEnvironment(macCatalyst) && canImport(AppKit)
        let adbConnectionProcess = Process()
        adbConnectionProcess.currentDirectoryURL = adbDirectoryUrl
        adbConnectionProcess.launchPath = "/bin/zsh"
        adbConnectionProcess.environment = [
            "home": Shell.userHomeDirectory.path,
            "LC_ALL": "en_US.UTF-8",
            "LANG": "en_US.UTF-8"
        ]
        adbConnectionProcess.arguments = [ "-l", "-c", "./adb -s \(serialId) logcat -s -v raw robologs.auto.android:V" ]

        let pipeOutput = Pipe()
        let pipeError = Pipe()
        adbConnectionProcess.standardOutput = pipeOutput
        adbConnectionProcess.standardError = pipeError

        var data: Data = Data()
        var outputLog = ""
        var errorLog = ""

        let gatherOutput: (Pipe, @escaping (String) -> Void) -> Void = { pipe, gatherer in
            self.workingQueue.async {
                while true {
                    do {
                        if let newData = try pipe.fileHandleForReading.read(upToCount: 8), !newData.isEmpty {
                            data.append(newData)

                            if let string = String(data: data, encoding: String.Encoding.utf8) {
                                data.removeAll()
                                gatherer(string)
                            }
                        } else {
                            break
                        }
                    } catch {
                        self.logger.error(error)
                    }
                }

                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    data.removeAll()
                    self.workingQueue.async {
                        gatherer(string)
                    }
                }
            }
        }

        gatherOutput(pipeOutput) { outputLog += $0 }
        gatherOutput(pipeError) { errorLog += $0 }

        logger.verbose("ADB Monitoring. Searching device \(serialId)")
        adbConnectionProcess.launch()
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1) {
            adbConnectionProcess.terminate()
        }
        adbConnectionProcess.waitUntilExit()

        logger.verbose(
            "Output: \(outputLog.replacingOccurrences(of: "\n", with: " ")); Error: \(errorLog.replacingOccurrences(of: "\n", with: " "))"
        )
        return outputLog
            .components(separatedBy: "\n")
            .filter { $0.hasPrefix("robologsId:") && $0.count >= 48 }
            .map { $0.replacingOccurrences(of: "robologsId:", with: "").trimmingCharacters(in: .whitespacesAndNewlines) }
        #else
        logger.warning("ADB Monitoring can be started only on macOS")
        return []
        #endif
    }

    // MARK: - Subscriptions

    private var foundSDKsById: [String: RobologsRemoteSDK] = [:]
    private var subscriptions: [String: ([RobologsRemoteSDK]) -> Void] = [:]

    public func subscribeOnSDKsListUpdate(listener: @escaping ([RobologsRemoteSDK]) -> Void) -> Subscription {
        let id = UUID().uuidString
        subscriptions[id] = listener
        let sources = Array(foundSDKsById.values)
        completionQueue.async {
            listener(Array(sources))
        }
        return Subscription {
            self.subscriptions[id] = nil
        }
    }

    private func notify() {
        let sources = Array(foundSDKsById.values)
        completionQueue.async { [weak self] in
            self?.subscriptions.values.forEach { $0(sources) }
        }
    }

    // MARK: - NetServiceBrowser Delegate

    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        logger.debug("")
    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        logger.debug("")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        logger.debug("Error: \(errorDict)")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        logger.debug("")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        logger.debug("")
    }

    private var foundRobologsServices: [NetService] = []
    private var foundAppleUSBConnectedServices: [NetService] = []

    private var appleUSBConnectedIPs: Set<String> = []
    private var androidADBConnectedIds: Set<String> = []
    // TODO: Need to remove these from this list after timeout? Maybe? Or not?

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        logger.verbose("Found: \(service.domain)/\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                needCheckAdb = true
                foundRobologsServices.append(service)
                service.delegate = self
                workingQueue.async {
                    service.resolve(withTimeout: 5)
                }
            case typeRemoteDebugLink:
                foundAppleUSBConnectedServices.append(service)
                service.delegate = self
                workingQueue.async {
                    service.resolve(withTimeout: 5)
                }
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
                foundRobologsServices = foundRobologsServices.filter { $0 !== service }
            case typeRemoteDebugLink:
                service.delegate = nil
                removeRemoteDebugLinkAddresses(from: service)
                foundAppleUSBConnectedServices = foundAppleUSBConnectedServices.filter { $0 !== service }
            default:
                break
        }
    }

    // MARK: - Connecting/Disconnecting

    private func addRemoteDebugLinkAddresses(from service: NetService) {
        let addresses = resolveIPv4(addresses: service.addresses ?? [])
        appleUSBConnectedIPs.formUnion(addresses)
        foundIOSLocalDevice(deviceAddresses: addresses)
        logger.debug("Found Remote Debug Links with addresses: \(addresses)")
    }

    private func removeRemoteDebugLinkAddresses(from service: NetService) {
        let addresses = resolveIPv4(addresses: service.addresses ?? [])
        appleUSBConnectedIPs.subtract(addresses)
        logger.debug("Removed Remote Debug Link addresses: \(addresses)")
    }

    private var localRobologSDKsByNetServiceName: [String: String] = [:]
    private var foundRobologSDKsByNetServiceName: [String: String] = [:]

    private func tryToConnect(to service: NetService) {
        guard !foundRobologSDKsByNetServiceName.keys.contains(service.name) else { return }
        guard let txtRecord = service.txtRecordData().map({ NetService.dictionary(fromTXTRecord: $0) }) else {
            logger.warning("Can't connect to \(service.domain)/\(service.type)/\(service.name)")
            return
        }

        let txtData = txtRecord.compactMapValues { String(data: $0, encoding: .utf8) }

        guard
            let name = txtData[BonjourServer.recordName],
            let senderId = txtData[BonjourServer.recordSenderId]
        else {
            logger.warning("Service does not have sender info: \(service.domain)/\(service.type)/\(service.name)")
            return
        }

        // Now we've either "regular server" and its address here, or "local server", that should be connected directly.
        // It's IP is service IP in this case.

        foundRobologSDKsByNetServiceName[service.name] = senderId
        let addresses = resolveIPv4(addresses: service.addresses ?? [])

        let endpoint = txtData[BonjourServer.recordEndpoint]
        let localBroadcastPort = txtData[BonjourServer.recordLocalServerPort]

        if let endpoint = endpoint, let endpointUrl = URL(string: endpoint) {
            let remoteSDK = RobologsRemoteSDK(name: name, id: senderId, apiEndpoint: endpointUrl, isLocalBroadcast: false)
            foundSDKsById[senderId] = remoteSDK
            notify()

            isRobologsServiceLocal(addresses: addresses, txtData: txtData) { isLocal in
                guard isLocal else {
                    return self.logger.debug("Not local service: \(service.domain)/\(service.type)/\(service.name)")
                }

                self.localRobologSDKsByNetServiceName[service.name] = senderId
                self.completionQueue.async { [weak self] in
                    self?.serviceFound?(remoteSDK)
                }
                self.logger.debug("Robologs service appeared with senderId: \(senderId)")
            }
        } else if let port = localBroadcastPort, !addresses.isEmpty, let endpointUrl = URL(string: "http://\(addresses[0]):\(port)") {
            let remoteSDK = RobologsRemoteSDK(name: name, id: senderId, apiEndpoint: endpointUrl, isLocalBroadcast: true)
            foundSDKsById[senderId] = remoteSDK
            notify()

            let addresses = resolveIPv4(addresses: service.addresses ?? [])
            isRobologsServiceLocal(addresses: addresses, txtData: txtData) { isLocal in
                guard isLocal else {
                    return self.logger.debug("Not local service: \(service.domain)/\(service.type)/\(service.name)")
                }

                self.localRobologSDKsByNetServiceName[service.name] = senderId
                self.completionQueue.async { [weak self] in
                    self?.serviceFound?(remoteSDK)
                }
                self.logger.debug("Robologs service appeared with senderId: \(senderId)")
            }
        }
    }

    private func disconnect(from service: NetService) {
        guard let senderId = foundRobologSDKsByNetServiceName[service.name] else { return }

        foundRobologSDKsByNetServiceName[service.name] = nil
        localRobologSDKsByNetServiceName[service.name] = nil

        if let remoteSDK = foundSDKsById[senderId] {
            foundSDKsById[senderId] = nil
            completionQueue.async {
                self.serviceDisappeared?(remoteSDK)
                self.notify()
            }
        }

        logger.debug("Robologs service disappeared with senderId: \(senderId)")
    }

    // MARK: - NetService Delegate

    public func netServiceDidResolveAddress(_ service: NetService) {
        logger.debug("Found: \(service.domain)/\(service.type)/\(service.name)")
        switch service.type {
            case typeRobologs:
                workingQueue.async {
                    self.tryToConnect(to: service)
                }
            case typeRemoteDebugLink:
                addRemoteDebugLinkAddresses(from: service)
            default:
                break
        }
    }

    public func netServiceDidStop(_ sender: NetService) {
        logger.debug("Did Stop")
    }

    public func netService(_ service: NetService, didNotResolve errorDict: [String: NSNumber]) {
        logger.debug("Error: \(errorDict)")
    }

    // MARK: - Helper Methods

    private func isRobologsServiceLocal(addresses: [String], txtData: [String: String], completion: @escaping (Bool) -> Void) {
        guard !addresses.contains("127.0.0.1") else {
            logger.debug("Robologs service is on localhost. Good!")
            return completion(true)
        }
        guard !addresses.contains(where: { appleUSBConnectedIPs.contains($0) }) else {
            logger.debug("Robologs service address is in Remote Debug Link addresses. Good!")
            return completion(true)
        }

        let simulatorId = txtData[BonjourServer.recordIOSSimulator]
        let androidId = txtData[BonjourServer.recordAndroidId]
        if let simulatorId = simulatorId {
            let command = Shell.ZSHCommandLine(command: "instruments -s devices", directory: Shell.userHomeDirectory, logger: logger)
            command.execute { _, _, output, _ in
                let hashedUDIDs: [String] = output
                    .components(separatedBy: "\n")
                    .filter { $0 != "Known Devices:" && !$0.isEmpty }
                    .compactMap { string in
                        guard let left = string.firstIndex(of: "["), let right = string.firstIndex(of: "]") else { return nil }

                        let udid = string[left ..< right].dropFirst()
                        self.logger.verbose("  Found device UDID: \"\(udid)\"")
                        return sha256(string: String(udid))
                    }

                let isLocalUDID = hashedUDIDs.contains(simulatorId)
                self.logger.debug(
                    isLocalUDID
                        ? "> \(BonjourServer.recordIOSSimulator) from TXT (\(simulatorId)) matched local UDID. Good!"
                        : "> \(BonjourServer.recordIOSSimulator) from TXT not found in local UDIDs"
                )
                completion(isLocalUDID)
            }
        } else if let androidId = androidId {
            collectAdbRobologIds()
            let isLocalId = androidADBConnectedIds.contains(androidId)
            completion(isLocalId)
        } else {
            completion(false)
        }
    }

    private func resolveIPv4(addresses: [Data]) -> [String] {
        addresses.compactMap { address in
            let data = address as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)

            let family = Int32(storage.ss_family)
            if family == AF_INET || family == AF_LOCAL {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                }

                return String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii)
            } else {
                return nil
            }
        }
    }

    // MARK: - Check if found device matches local device

    private func foundAndroidLocalDevice(id androidRobologsId: String) {
        foundRobologsServices.forEach { robologsService in
            guard let txtRecord = robologsService.txtRecordData().map({ NetService.dictionary(fromTXTRecord: $0) }) else { return }
            guard
                let androidIdData = txtRecord[BonjourServer.recordAndroidId],
                let androidId = String(data: androidIdData, encoding: .utf8)
            else { return }

            if androidId == androidRobologsId {
                tryToConnect(to: robologsService)
            }
        }
    }

    private func foundIOSLocalDevice(deviceAddresses: [String]) {
        foundRobologsServices.forEach { robologsService in
            guard let addressesData = robologsService.addresses else { return }

            let addresses = resolveIPv4(addresses: addressesData)
            if deviceAddresses.contains(where: { addresses.contains($0) }) {
                tryToConnect(to: robologsService)
            }
        }
    }
}
