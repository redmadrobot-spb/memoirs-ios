//
// WithMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

// TODO: Waiting for this: https://github.com/apple/swift-evolution/blob/main/proposals/0415-function-body-macros.md
//@freestanding(expression)
//public macro createLocalMemoir() = #externalMacro(module: "Macros", type: "CreateMemoirMacro")

@attached(member, names: named($typeTracer), named($typeMemoir), named($createLocalMemoir))
public macro WithMemoir(_ memoirBuilder: Any) = #externalMacro(module: "Macros", type: "WithMemoirMacro")

@attached(member, names: named($node), named($declaration))
public macro TraceTheSyntax(_: Any) = #externalMacro(module: "Macros", type: "TraceTheSyntax")
