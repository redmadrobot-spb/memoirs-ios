//
// WithMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

@attached(member, names: named($memoir), named($tracer))
public macro WithMemoir() = #externalMacro(module: "MemoirMacros", type: "WithMemoirMacro")
