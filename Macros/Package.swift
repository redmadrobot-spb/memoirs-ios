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
    name: "Macros",
    platforms: [ .iOS(.v14), .macOS(.v12) ],
    products: [
        .library(name: "MemoirMacrosLibrary", targets: [ "MemoirMacros" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.0"),
    ],
    targets: [
        .macro(
            name: "MemoirMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources"
        ),
        .executableTarget(name: "MemoirMacroExample", dependencies: [ "MemoirMacros" ], path: "Sources.Example"),
        .testTarget(name: "MemoirMacrosTest", dependencies: [ "MemoirMacros", .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"), ], path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
