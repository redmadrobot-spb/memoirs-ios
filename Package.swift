// swift-tools-version:5.9
//
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v14), .tvOS(.v14), .watchOS(.v8), .macOS(.v13), .macCatalyst(.v14) ],
    products: [
        .library(name: "Memoirs", targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    dependencies: [
        .package(name: "MemoirMacros", path: "Macros"),
    ],
    targets: [
        .target(name: "MemoirsWorkaroundC", dependencies: [], path: "Sources.Workaround"),
        .target(
            name: "Memoirs",
            dependencies: [ 
                "MemoirsWorkaroundC", 
                .product(name: "MemoirMacros", package: "MemoirMacros")
            ],
            path: "Sources",
            swiftSettings: swiftSettings
        ),

        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),
        .executableTarget(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),
    ],
    swiftLanguageVersions: [.v5]
)
