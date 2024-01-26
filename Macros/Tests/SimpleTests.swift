//
// main
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import Foundation
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

import Macros

class SimpleTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "WithMemoir": WithMemoirMacro.self,
    ]

    func testEmpty() throws {
        assertMacroExpansion(
                #"""
                @WithMemoir({ PrintMemoir() })
                class Test {
                }
                """#,
            expandedSource:
                """
                class Test {

                    var $tracer: Tracer = .type(Test.self)

                    var $memoir: TracedMemoir = TracedMemoir(tracer: .type(Test.self), memoir: {
                            PrintMemoir()
                        }())
                }
                """,
            macros: testMacros
        )
    }
}
