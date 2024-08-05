//
// WithMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

@attached(member, names: named($memoirTracer), named($memoir))
public macro WithTracer() = #externalMacro(module: "Macros", type: "WithTracerMacro")
@attached(body)
public macro AutoTraced() = #externalMacro(module: "Macros", type: "AutoTracedMacro")
