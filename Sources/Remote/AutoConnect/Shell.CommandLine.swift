//
// Shell.CommandLine
// Robologs
//
// Created by Alex Babaev on 28 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

enum Shell {
    private(set) static var userHomeDirectory: URL = {
        guard
            let passwd = getpwuid(getuid()),
            let home = passwd.pointee.pw_dir
        else { fatalError("No rights :(") }

        let homeDirectory = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
        return URL(fileURLWithPath: homeDirectory)
    }()

    class CommandLine {
        let shell: String
        let directory: URL
        let command: String

        enum State {
            case notStarted
            case inProgress(output: String, tailOutput: String, error: String, tailError: String)
            case success(output: String, error: String)
            case failure(output: String, error: String, code: Int32)
        }

        var stateHandler: ((State) -> Void)?

        private(set) var state: State = .notStarted {
            didSet {
                stateHandler?(state)
            }
        }

        private var logger: LabeledLogger!

        init(shell: String = "/bin/zsh", in directory: URL, command: String, logger: Logger) {
            self.shell = shell
            self.directory = directory
            self.command = command
            self.logger = LabeledLogger(object: self, logger: logger)
        }

        @discardableResult
        func execute() -> String {
            #if canImport(AppKit)
            let process = Process()
            process.currentDirectoryURL = directory
            process.launchPath = shell
            process.environment = [
                "home": Shell.userHomeDirectory.path,
                "LC_ALL": "en_US.UTF-8",
                "LANG": "en_US.UTF-8"
            ]
            process.arguments = [
                "-l",
                "-c",
                // These helper commands are needed for me (for rvm and for fastlane).
                // TODO: They must be moved to a config someday
                "source ~/.rvm/scripts/rvm && " + command + ""
            ]

            let pipeOutput = Pipe()
            let pipeError = Pipe()
            process.standardOutput = pipeOutput
            process.standardError = pipeError

            var data: Data = Data()
            var output = ""
            var error = ""

            let gatherOutput: (Pipe, @escaping (String) -> Void) -> Any = { pipe, gatherer in
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                let newDataNotification = NSNotification.Name.NSFileHandleDataAvailable
                let center = NotificationCenter.default
                // swiftlint:disable:next discarded_notification_center_observer
                return center.addObserver(forName: newDataNotification, object: pipe.fileHandleForReading, queue: nil) { _ in
                    guard process.isRunning else { return }

                    while true {
                        do {
                            if let newData = try pipe.fileHandleForReading.read(upToCount: 1024), !newData.isEmpty {
                                data.append(newData)
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
                        gatherer(string)
                    }
                    do {
                        _ = try pipe.fileHandleForReading.read(upToCount: 0)
                        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                    } catch {
                        self.logger.error(error)
                    }
                }
            }

            let outputObserver = gatherOutput(pipeOutput) { string in
                output += string
                self.state = .inProgress(output: output, tailOutput: string, error: error, tailError: "")
            }
            let errorObserver = gatherOutput(pipeError) { string in
                error += string
                self.state = .inProgress(output: output, tailOutput: "", error: error, tailError: string)
            }

            process.terminationHandler = { process in
                NotificationCenter.default.removeObserver(outputObserver)
                NotificationCenter.default.removeObserver(errorObserver)
            }

            state = .inProgress(output: output, tailOutput: output, error: error, tailError: error)
            process.launch()
            process.waitUntilExit()
            if !output.isEmpty {
                output += "\n"
                state = .inProgress(output: output, tailOutput: "\n", error: error, tailError: "")
            }

            // I can't do this immediately because if I do that, notification will break :(
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                try? pipeOutput.fileHandleForReading.close()
                try? pipeError.fileHandleForReading.close()
            }

            state = process.terminationStatus == 0
                ? .success(output: output, error: error)
                : .failure(output: output, error: error, code: process.terminationStatus)

            return output
            #else
            fatalError("Not supported")
            #endif
        }
    }
}
