// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Robologs",
    products: [
        .library(
            name: "Robologs",
            targets: [ "Robologs" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0")
    ],
    targets: [
        .target(name: "Robologs", dependencies: ["SwiftProtobuf"], path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
