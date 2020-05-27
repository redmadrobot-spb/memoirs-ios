//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

let androidHome = ProcessInfo.processInfo.environment["ANDROID_HOME"]
if androidHome == nil {
    print("Set up ANDROID_HOME environment variable to Android SDK root be able to listen for Android devices automatically")
}

let client = BonjourClient(adbRunDirectory: androidHome.map { "\($0)/platform-tools" }, logger: PrintLogger(onlyTime: true))
let subscription = client.subscribeOnSDKsListUpdate { list in
    print("\nFound!\n\(list)\n")
}

RunLoop.main.run()

//    struct PossibleJSON: CustomStringConvertible {
//        let string: String
//
//        var start: String.Index
//        var end: String.Index?
//
//        var children: [PossibleJSON]
//
//        func with(end: String.Index) -> PossibleJSON {
//            var result = self
//            result.end = end
//            return result
//        }
//
//        var description: String {
//            if let end = end {
//                return String(string[start ..< end])
//            } else {
//                return children.isEmpty ? "" : "\(children)"
//            }
//        }
//    }
//
//    func findPossibleJSONs(
//        in string: String,
//        range: Range<String.Index>? = nil,
//        endingCharacter: Character? = nil
//    ) -> (end: String.Index?, possibilities: [PossibleJSON]) {
//        let range = range ?? (string.startIndex ..< string.endIndex)
//
//        var stringStartCharacter: Character?
//        var isEscaping = false
//
//        var result: [PossibleJSON] = []
//        var lastParsedIndex: String.Index?
//
//        var index = range.lowerBound
//        while index != range.upperBound && lastParsedIndex == nil {
//            let currentIndex = index
//            index = string.index(after: index)
//
//            guard !isEscaping else {
//                isEscaping = false
//                continue
//            }
//
//            let character = string[currentIndex]
//            switch character {
//                case "\"", "'":
//                    if stringStartCharacter == nil {
//                        stringStartCharacter = character
//                    } else {
//                        stringStartCharacter = nil
//                    }
//                case "\\":
//                    isEscaping = true
//                case "{", "[":
//                    guard stringStartCharacter == nil else { break }
//
//                    let endingCharacter: Character = character == "{" ? "}" : "]"
//                    let (endIndex, children) =
//                        findPossibleJSONs(in: string, range: index ..< range.upperBound, endingCharacter: endingCharacter)
//                    index = endIndex ?? range.upperBound
//                    result.append(PossibleJSON(string: string, start: currentIndex, end: endIndex, children: children))
//                case "}", "]":
//                    guard stringStartCharacter == nil else { break }
//                    guard endingCharacter == character else { break }
//
//                    lastParsedIndex = index
//                default:
//                    break
//            }
//        }
//
//        return (lastParsedIndex, result)
//    }
//
//    let tests: [(test: String, correct: String)] = [
//        ("{ foo }", "[{ foo }]"),
//        ("[ foo ]", "[[ foo ]]"),
//        ("[{ foo }]", "[[{ foo }]]"),
//        ("{ foo ]", "[]"),
//        ("{ ] }", "[{ ] }]"),
//        ("{ foo: [] }", "[{ foo: [] }]"),
//        ("bar { foo }", "[{ foo }]"),
//        ("{ foo } bar", "[{ foo }]"),
//        ("[ foo } bar", "[]"),
//        ("[ { ] }", "[[{ ] }]]"),
//        ("{ { foo1 }", "[[{ foo1 }]]"),
//        ("[ { foo1 }, { foo2 }", "[[{ foo1 }, { foo2 }]]"),
//        ("[{}, {}, {}, [{}, {}][]", "[[{}, {}, {}, [{}, {}], []]]"),
//    ]
//    tests.forEach { test, correct in
//        let possibleJSONs = findPossibleJSONs(in: test).possibilities
//        let result = "\(possibleJSONs)"
//        if result != correct {
//            print("Test: \"\(test)\" Got: \"\(result)\" Correct: \"\(correct)\"")
//        } else {
//            print("Test: \"\(test)\" Passed")
//        }
//    }
