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

public struct WithMemoirMacro: MemberMacro {
    enum Problem: Error {
        case shouldBeAttachedToType
        case problemWithExpression(String)
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
        let parameter = try getParentMemoirBuilder(from: node)
        return [
            "private static let $typeTracer: Tracer = .type(\(raw: name).self)",

            """
            private static let $typeMemoir: TracedMemoir = TracedMemoir(
                tracer: \(raw: name).$typeTracer,
                memoir: { 
                    \(raw: parameter)
                }()
            )
            """,

            """
            private func $createLocalMemoir() -> TracedMemoir {
                Tracing.localValue?.with(tracer: \(raw: name).$typeTracer) ?? \(raw: name).$typeMemoir
            }
            """
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

    static func getParentMemoirBuilder(from node: SwiftSyntax.AttributeSyntax) throws -> ExprSyntax {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw Problem.problemWithExpression("Arguments")
        }
        guard let argument = arguments.first?.as(LabeledExprSyntax.self) else {
            throw Problem.problemWithExpression("First Argument")
        }

        return argument.expression.trimmed
    }
}
