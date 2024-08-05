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
        of node: SwiftSyntax.AttributeSyntax,
        providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let statements = declaration.body?.statements else { return [] }

        return [
            """
            AutoTracingContext.$memoir.withValue(AutoTracingContext.memoir.withUnique(tracer: Self.$memoirTracer)) {
                let $memoir = self.$memoir     
                \(statements)
            }
            """
        ]
    }
}
