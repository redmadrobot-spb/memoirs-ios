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

class AutoTracedTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "WithTracer": WithTracerMacro.self,
        "AutoTraced": AutoTracedMacro.self,
    ]

    func testEmpty() throws {
        assertMacroExpansion(
                #"""
                @WithTracer
                class Test {
                    @AutoTraced
                    func foo() {
                        $memoir.debug("Debug log")
                    }
                }
                """#,
            expandedSource:
                """
                class Test {
                    func foo() {
                        AutoTracingContext.$memoir.withValue(AutoTracingContext.memoir.withUnique(tracer: Self.$memoirTracer)) {
                            let $memoir = self.$memoir

                                    $memoir.debug("Debug log")
                        }
                    }
                
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
