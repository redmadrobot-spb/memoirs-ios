// swift-tools-version:5.5
//
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(
        ["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"], .when(configuration: .debug)
    )
]

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v13), .macOS(.v12) ],
    products: [
        .library(name: "Memoirs", targets: [ "MemoirsC", "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    targets: [
        // TODO: Remove this when concurrency starts to work with global vars.
        .target(name: "MemoirsC", dependencies: [], path: "Sources.CHelpers"),
        .target(name: "Memoirs", dependencies: [ "MemoirsC" ], path: "Sources", swiftSettings: swiftSettings),
        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),
        .target(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),
    ],
    swiftLanguageVersions: [.v5]
)
