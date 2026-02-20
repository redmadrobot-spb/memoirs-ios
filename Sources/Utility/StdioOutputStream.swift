//
// StdioOutputStream.swift
// Memoirs
//
// Created by Alexander Babaev on 20 February 2026
// Copyright © 2024 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//
// Attribution: #swift-log
//

#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import CRT
#elseif canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Android)
@preconcurrency import Android
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#else
#error("Unsupported runtime")
#endif

#if canImport(WASILibc) || os(Android)
internal typealias CFilePointer = OpaquePointer
#else
internal typealias CFilePointer = UnsafeMutablePointer<FILE>
#endif

/// A wrapper to facilitate `print`-ing to stderr and stdio that
/// ensures access to the underlying `FILE` is locked to prevent
/// cross-thread interleaving of output.
internal struct StdioOutputStream: TextOutputStream, @unchecked Sendable {
    internal let file: CFilePointer
    internal let flushMode: FlushMode

    internal func write(_ string: String) {
        self.contiguousUTF8(string).withContiguousStorageIfAvailable { utf8Bytes in
            #if os(Windows)
            _lock_file(self.file)
            #elseif canImport(WASILibc)
            // no file locking on WASI
            #else
            flockfile(self.file)
            #endif
            defer {
                #if os(Windows)
                _unlock_file(self.file)
                #elseif canImport(WASILibc)
                // no file locking on WASI
                #else
                funlockfile(self.file)
                #endif
            }
            _ = fwrite(utf8Bytes.baseAddress!, 1, utf8Bytes.count, self.file)
            if case .always = self.flushMode {
                self.flush()
            }
        }!
    }

    /// Flush the underlying stream.
    internal func flush() {
        _ = fflush(self.file)
    }

    internal func contiguousUTF8(_ string: String) -> String.UTF8View {
        var contiguousString = string
        contiguousString.makeContiguousUTF8()
        return contiguousString.utf8
    }

    internal static let stderr = {
        // Prevent name clashes
        #if canImport(Darwin)
        let systemStderr = Darwin.stderr
        #elseif os(Windows)
        let systemStderr = CRT.stderr
        #elseif canImport(Glibc)
        let systemStderr = Glibc.stderr!
        #elseif canImport(Android)
        let systemStderr = Android.stderr
        #elseif canImport(Musl)
        let systemStderr = Musl.stderr!
        #elseif canImport(WASILibc)
        let systemStderr = WASILibc.stderr!
        #else
        #error("Unsupported runtime")
        #endif
        return StdioOutputStream(file: systemStderr, flushMode: .always)
    }()

    internal static let stdout = {
        // Prevent name clashes
        #if canImport(Darwin)
        let systemStdout = Darwin.stdout
        #elseif os(Windows)
        let systemStdout = CRT.stdout
        #elseif canImport(Glibc)
        let systemStdout = Glibc.stdout!
        #elseif canImport(Android)
        let systemStdout = Android.stdout
        #elseif canImport(Musl)
        let systemStdout = Musl.stdout!
        #elseif canImport(WASILibc)
        let systemStdout = WASILibc.stdout!
        #else
        #error("Unsupported runtime")
        #endif
        return StdioOutputStream(file: systemStdout, flushMode: .always)
    }()

    /// Defines the flushing strategy for the underlying stream.
    internal enum FlushMode {
        case undefined
        case always
    }
}
