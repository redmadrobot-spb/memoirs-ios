//
// FileMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 27 December 2019. Updated by Alex Babaev
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// `(Memoir)` implementation which outputs logs to the specified file.
/// `FileMemoir` uses the same configuration as `(PrintMemoir)`.
public final class FileMemoir: Memoir {
    @usableFromInline
    let time: PrintMemoir.Time
    @usableFromInline
    let output: Output

    @usableFromInline
    let interceptor: (@Sendable (String) -> Void)?

    @usableFromInline
    let fileUrl: URL
    @usableFromInline
    let maxFileSizeBytes: Int

    /// Creates a new instance of `PrintMemoir`.
    public init(
        fileUrl: URL,
        maxFileSizeBytes: Int = 1024 * 1024 * 50, // 50 MB
        time: PrintMemoir.Time = .formatter(PrintMemoir.timeOnlyDateFormatter),
        codePosition: PrintMemoir.CodePosition = .short,
        shortTracers: Bool = true,
        markers: Output.Markers = .init(),
        tracerFilter: @escaping @Sendable (Tracer) -> Bool = PrintMemoir.defaultTracerFilter,
        interceptor: (@Sendable (String) -> Void)? = nil
    ) {
        self.fileUrl = fileUrl
        self.maxFileSizeBytes = maxFileSizeBytes
        output = Output(
            markers: markers,
            hideSensitiveValues: false,
            codePositionType: codePosition,
            shortTracers: shortTracers, separateTracers: true,
            tracerFilter: tracerFilter
        )
        self.time = time
        self.interceptor = interceptor
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        message: @autoclosure () throws -> SafeString,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) rethrows {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        var parts: [String]
        switch item {
            case .log(let level):
                parts = try output.logString(
                    date: time.string(from: timeIntervalSinceReferenceDate), level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .event(let name):
                parts = output.eventString(
                    date: time.string(from: timeIntervalSinceReferenceDate), name: name, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, false):
                parts = output.tracerString(
                    date: time.string(from: timeIntervalSinceReferenceDate), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, true):
                parts = output.tracerEndString(
                    date: time.string(from: timeIntervalSinceReferenceDate), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .measurement(let name, let value):
                parts = output.measurementString(
                    date: time.string(from: timeIntervalSinceReferenceDate), name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                )
        }
        parts.append("\n")

        let toOutput = parts.joined(separator: " ")
        do {
            try toOutput.append(toFile: fileUrl)

        } catch {
            NSLog("Error while writing log to the file “\(fileUrl)”: \(error)")
        }
        interceptor?(toOutput)
    }

    private func rotateLogFile() {
        if let resourceValues = try? fileUrl.resourceValues(forKeys: [ .fileSizeKey ]), resourceValues.fileSize ?? 0 > maxFileSizeBytes {
            let otherLogFile = fileUrl.appendingPathExtension(".previous")
            do {
                try FileManager.default.removeItem(at: otherLogFile)
                try FileManager.default.moveItem(at: fileUrl, to: otherLogFile)
            } catch {
                NSLog("Error while rotating log file “\(fileUrl)” with “\(otherLogFile)” \(error)")
            }
        }
    }
}

public extension String {
    func append(toFile fileUrl: URL) throws {
        let data = Data(self.utf8)
        if let fileHandle = try? FileHandle(forWritingTo: fileUrl) {
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            try data.write(to: fileUrl, options: .atomic)
        }
    }
}
