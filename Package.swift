// swift-tools-version:5.3
//
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import PackageDescription

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Memoirs", targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    targets: [
        .target(name: "Memoirs", dependencies: [], path: "Sources"),
        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),
        .target(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),
    ],
    swiftLanguageVersions: [.v5]
)
