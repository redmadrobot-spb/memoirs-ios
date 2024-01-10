// swift-tools-version:5.9
//
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import PackageDescription
import CompilerPluginSupport

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v14), .tvOS(.v14), .watchOS(.v8), .macOS(.v13) ],
    products: [
        .library(name: "Memoirs", targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.0"),
    ],
    targets: [
        .target(name: "MemoirsWorkaroundC", dependencies: [], path: "Sources.Workaround"),
        .target(name: "Memoirs", dependencies: [ "MemoirsWorkaroundC", "MemoirMacros" ], path: "Sources", swiftSettings: swiftSettings),

        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs", "MemoirMacros" ]),
        .executableTarget(name: "ExampleMemoirs", dependencies: [ "Memoirs", "MemoirMacros" ], path: "Sources.Example"),

        .macro(
            name: "MemoirMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Macros"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
