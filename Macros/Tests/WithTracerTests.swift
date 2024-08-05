//
// WithTracerTests
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

class WithTracerTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "WithTracer": WithTracerMacro.self,
    ]

    func testEmpty() throws {
        assertMacroExpansion(
                #"""
                @WithTracer
                class Test {
                }
                """#,
            expandedSource:
                """
                class Test {
                
                    private static let $memoirTracer: Tracer = .type(Test.self)
                
                    private var $memoir: TracedMemoir {
                        AutoTracingContext.memoir
                    }
                }
                """,
            macros: testMacros
        )
    }
}
