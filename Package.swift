// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Memoirs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Memoirs", type: .static, targets: [ "Memoirs" ]),
        .executable(name: "ExampleMemoirs", targets: [ "ExampleMemoirs" ]),
    ],
    targets: [
        .target(name: "ExampleMemoirs", dependencies: [ "Memoirs" ], path: "Sources.Example"),

        .target(name: "Memoirs", dependencies: [], path: "Sources"),
        .testTarget(name: "MemoirsTests", dependencies: [ "Memoirs" ]),
    ],
    swiftLanguageVersions: [.v5]
)
