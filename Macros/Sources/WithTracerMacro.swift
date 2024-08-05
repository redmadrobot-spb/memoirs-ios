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

public struct WithTracerMacro: MemberMacro {
    enum Problem: Error {
        case shouldBeAttachedToType
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
        let name = try self.name(providingMembersOf: declaration)
        return [
            "private static let $memoirTracer: Tracer = .type(\(raw: name).self)",
            "private var $memoir: TracedMemoir { AutoTracingContext.memoir }",
        ]
    }

    private static func name(providingMembersOf declaration: some DeclGroupSyntax) throws -> TokenSyntax {
        if let decl = declaration.as(ClassDeclSyntax.self) {
            decl.name.trimmed
        } else if let decl = declaration.as(StructDeclSyntax.self) {
            decl.name.trimmed
        } else if let decl = declaration.as(EnumDeclSyntax.self) {
            decl.name.trimmed
        } else {
            throw Problem.shouldBeAttachedToType
        }
    }
}
