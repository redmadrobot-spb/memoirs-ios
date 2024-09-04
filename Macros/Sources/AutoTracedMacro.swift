//
// WithMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct AutoTracedMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let statements = declaration.body?.statements else { return [] }

        let isAsync = declaration.as(FunctionDeclSyntax.self)?.signature.effectSpecifiers?.asyncSpecifier != nil
        return if isAsync {
            [
                """
                let $memoir = AutoTracingContext.memoir.withUnique(tracer: Self.$memoirTracer)
                await AutoTracingContext.$memoir.withValue($memoir) {
                \(statements)
                }
                """
            ]
        } else {
            [
                """
                let $memoir = AutoTracingContext.memoir.withUnique(tracer: Self.$memoirTracer)
                AutoTracingContext.$memoir.withValue($memoir) {
                \(statements)
                }
                """
            ]
        }
    }
}
