// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Robologs",
    platforms: [ .iOS(.v11), .macOS(.v10_15) ],
    products: [
        .library(name: "Robologs", type: .static, targets: [ "Robologs" ]),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0"),
    ],
    targets: [
        .target(name: "Robologs", dependencies: [ "SwiftProtobuf" ], path: "", sources: [ "Sources.Robologs", "Sources.Robologs.Remote" ]),
    ],
    swiftLanguageVersions: [.v5]
)
