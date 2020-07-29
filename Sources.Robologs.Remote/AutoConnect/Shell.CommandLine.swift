//
// Shell.CommandLine
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

enum Shell {
    private(set) static var userHomeDirectory: URL = {
        guard
            let passwd = getpwuid(getuid()),
            let home = passwd.pointee.pw_dir
        else { fatalError("No rights :(") }

        let homeDirectory = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
        return URL(fileURLWithPath: homeDirectory)
    }()

    class ZSHCommandLine {
        let directory: URL
        let command: String

        private let handlersQueue: DispatchQueue
        private let logger: LabeledLogger

        init(command: String, directory: URL, handlersQueue: DispatchQueue = DispatchQueue.main, logger: LabeledLogger) {
            self.directory = directory
            self.command = command
            self.handlersQueue = handlersQueue
            self.logger = logger
        }

        func execute(completion: @escaping (_ success: Bool, _ terminationCode: Int32, _ output: String, _ error: String) -> Void) {
            #if !targetEnvironment(macCatalyst) && canImport(AppKit)
            let completion: (Bool, Int32, String, String) -> Void = { success, terminationCode, output, error in
                self.handlersQueue.async { completion(success, terminationCode, output, error) }
            }

            let process = Process()
            process.currentDirectoryURL = directory
            process.launchPath = "/bin/zsh"
            process.environment = [
                "home": Shell.userHomeDirectory.path,
                "LC_ALL": "en_US.UTF-8",
                "LANG": "en_US.UTF-8"
            ]
            process.arguments = [
                "-l",
                "-c",
                command
            ]

            let pipeOutput = Pipe()
            let pipeError = Pipe()
            process.standardOutput = pipeOutput
            process.standardError = pipeError

            var data: Data = Data()

            let gatherOutput: (Pipe, @escaping (String) -> Void) -> Void = { pipe, gatherer in
                DispatchQueue.global().async {
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
                            break
                        }
                    }

                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                        data.removeAll()
                        DispatchQueue.main.async {
                            gatherer(string)
                        }
                    }
                }
            }

            var outputLog = ""
            var errorLog = ""
            gatherOutput(pipeOutput) { string in
                outputLog += string
            }
            gatherOutput(pipeError) { string in
                errorLog += string
            }

            process.launch()
            process.waitUntilExit()

            let success = process.terminationStatus == 0
            completion(success, process.terminationStatus, outputLog, errorLog)

            // I can't do this immediately because if I do that, notification will break :(
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                try? pipeOutput.fileHandleForReading.close()
                try? pipeError.fileHandleForReading.close()
            }
            #else
            fatalError("Not supported")
            #endif
        }
    }
}
