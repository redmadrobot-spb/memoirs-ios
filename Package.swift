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
    platforms: [ .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macOS(.v12) ],
    products: [
        .library(name: "Memoirs", targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    targets: [
        .target(name: "MemoirsWorkaroundC", dependencies: [], path: "Sources.Workaround"),
        .target(name: "Memoirs", dependencies: [ "MemoirsWorkaroundC" ], path: "Sources", swiftSettings: swiftSettings),

        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),
        .executableTarget(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),
    ],
    swiftLanguageVersions: [.v5]
)
