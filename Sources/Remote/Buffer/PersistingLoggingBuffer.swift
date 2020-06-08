//
// PersistingLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

class PersistingLoggingBuffer: RemoteLoggerBuffer {
    private let cachePath: URL

    private let maxBatchesCount: Int
    private let maxBatchSize: Int

    private var logger: LabeledLogger!

    init(cachePath: URL, maxBatchSize: Int, maxBatchesCount: Int, logger: Logger) {
        self.cachePath = cachePath
        self.maxBatchesCount = maxBatchesCount
        self.maxBatchSize = maxBatchSize
        self.logger = LabeledLogger(object: self, logger: logger)
        if !FileManager.default.fileExists(atPath: cachePath.path) {
            do {
                try FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true)
            } catch {
                self.logger.error(error)
            }
        }

        self.logger.info("Initialized")
    }

    private let queue: DispatchQueue = .init(label: "PersistingLoggingBuffer")

    func add(message: CachedLogMessage) {
        queue.async(flags: .barrier) {
            self.persist(record: message)
        }
    }

    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])? {
        queue.sync {
            guard let enumerator = FileManager.default.enumerator(atPath: cachePath.path) else { return nil }
            let batches = enumerator
                .compactMap { $0 as? String }
                .filter { $0 != savingBatchId }
                .sorted(by: <)
            while batches.count > maxBatchesCount {
                guard let url = batches.first.map({ URL(fileURLWithPath: $0) }) else { break }

                logger.debug("Removing archive batch file (number of batch files exceeded \(maxBatchesCount)) \"\(url.lastPathComponent)\"")
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    logger.error(error, message: "Error removing file \"\(url.lastPathComponent)\"")
                }
            }
            guard let id = batches.first.map({ URL(fileURLWithPath: $0).lastPathComponent }) else { return nil }

            return records(for: id).map { (id, $0) }
        }
    }

    func removeBatch(id: String) {
        queue.async(flags: .barrier) {
            do {
                let url = self.cachePath.appendingPathComponent(id)
                self.logger.debug("Removing archive batch file \"\(url.lastPathComponent)\"")
                try FileManager.default.removeItem(at: url)
            } catch {
                self.logger.error(error)
            }
        }
    }

    // MARK: - Logs Persistence

    private var savingBatchId: String?

    private func persist(record: CachedLogMessage) {
        let id: String
        var records: [CachedLogMessage]
        if let savingBatchId = savingBatchId {
            id = savingBatchId
            records = self.records(for: savingBatchId) ?? []
            records.append(record)

            if records.count > maxBatchSize {
                self.savingBatchId = nil
            }
        } else {
            id = "\(Int(Date.timeIntervalSinceReferenceDate))-\(UUID().uuidString)"
            self.logger.debug("Creating new batch id (and file) \"\(id)\"")
            savingBatchId = id
            records = [ record ]
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(records)
            try data.write(to: cachePath.appendingPathComponent(id), options: .atomic)
            self.logger.verbose("Persisted log with position \(record.position) \"\(id)\"")
        } catch {
            logger.error(error)
        }
    }

    private func records(for id: String) -> [CachedLogMessage]? {
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: cachePath.appendingPathComponent(id))
            return try decoder.decode([CachedLogMessage].self, from: data)
        } catch {
            logger.error(error)
            return nil
        }
    }
}
