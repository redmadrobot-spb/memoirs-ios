// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Memoirs", type: .static, targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),

        .library(name: "MemoirSubscriptions", type: .static, targets: [ "MemoirSubscriptions" ]),
    ],
    targets: [
        .target(name: "Memoirs", dependencies: [ "MemoirSubscriptions" ], path: "Sources"),
        .target(name: "MemoirSubscriptions", dependencies: [], path: "Sources.Subscriptions"),

        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),

        .target(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),
    ],
    swiftLanguageVersions: [.v5]
)
