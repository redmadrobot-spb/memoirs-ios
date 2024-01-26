//
// main
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MemoirMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
//        CreateMemoirMacro.self,
        TraceTheSyntaxMacro.self,
        WithMemoirMacro.self,
    ]
}
