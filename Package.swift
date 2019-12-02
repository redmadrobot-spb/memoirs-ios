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
    targets: [
        .target(name: "Robologs")
    ],
    swiftLanguageVersions: [.v5]
)
