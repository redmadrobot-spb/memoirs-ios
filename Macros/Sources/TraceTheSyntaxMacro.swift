//
// TraceTheSyntax
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct TraceTheSyntaxMacro: MemberMacro {
    enum Problem: Error {
        case trace(String)
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try expansion(of: node, providingMembersOf: declaration, conformingTo: [], in: context)
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return [
            #"""
            var $node: String =
            """
            \#(raw: node.debugDescription)
            """
            """#,

            #"""
            var $declaration: String =
            """
            \#(raw: declaration.debugDescription)
            """
            """#,
        ]
    }
}
