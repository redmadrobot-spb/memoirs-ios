// swift-tools-version:5.9
//
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "MemoirMacros",
    platforms: [ .macOS(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13) ],
    products: [
        .library(name: "MemoirMacros", targets: [ "MemoirMacros" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.0"),
    ],
    targets: [
        .target(name: "MemoirMacros", dependencies: [ "Macros", ], path: "Sources.Definitions"),

        .macro(
            name: "Macros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources"
        ),

        .executableTarget(
            name: "MemoirMacroExample",
            dependencies: [ "MemoirMacros" ], 
            path: "Sources.Example"
        ),

        .testTarget(
            name: "MemoirMacrosTest",
            dependencies: [
                "Macros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
