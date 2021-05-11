// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Robologs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Robologs", type: .static, targets: [ "Robologs" ]),
        .executable(name: "ExampleRobologs", targets: [ "ExampleRobologs" ]),
    ],
    targets: [
        .target(name: "ExampleRobologs", dependencies: [ "Robologs" ], path: "Sources.Example.Robologs"),

        .target(name: "Robologs", dependencies: [], path: "Sources.Robologs"),
        .testTarget(name: "TestRobologs", dependencies: [ "Robologs" ]),
    ],
    swiftLanguageVersions: [.v5]
)
