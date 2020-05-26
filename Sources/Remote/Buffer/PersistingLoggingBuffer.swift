//
// PersistingLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

class PersistingLoggingBuffer: RemoteLoggerBuffer {
    private(set) lazy var name: String = String(describing: type(of: self))
    let kind: RemoteLoggerBufferKind = .archive

    private let cachePath: URL
    private let saveBatchSize: Int
    private var logger: LabeledLogger!

    init(cachePath: URL, batchSize: Int, logger: Logger) {
        self.cachePath = cachePath
        self.saveBatchSize = batchSize
        self.logger = LabeledLogger(object: self, logger: logger)
        if !FileManager.default.fileExists(atPath: cachePath.path) {
            do {
                try FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true)
            } catch {
                self.logger.error(error)
            }
        }
    }

    private let queue: DispatchQueue = .init(label: "PersistingLoggingBuffer")

    func add(record: CachedLogMessage) {
        queue.async(flags: .barrier) {
            self.persist(record: record)
        }
    }

    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])? {
        queue.sync {
            let firstPath: String? = FileManager.default
                .enumerator(atPath: cachePath.path)?
                .first { name in (name as? String) != savingBatchId } as? String
            let batchId = firstPath.map { URL(fileURLWithPath: $0).lastPathComponent }
            guard let id = batchId else { return nil }

            return records(for: id).map { (id, $0) }
        }
    }

    func removeBatch(id: String) {
        queue.async(flags: .barrier) {
            do {
                try FileManager.default.removeItem(at: self.cachePath.appendingPathComponent(id))
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

            if records.count > saveBatchSize {
                self.savingBatchId = nil
            }
        } else {
            id = UUID().uuidString
            savingBatchId = id
            records = [ record ]
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(records)
            try data.write(to: cachePath.appendingPathComponent(id), options: .atomic)
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
