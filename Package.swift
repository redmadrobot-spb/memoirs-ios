// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Robologs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Robologs", type: .static, targets: [ "Robologs" ]),
        .library(name: "RobologsRemote", type: .static, targets: [ "RobologsRemote" ]),
        .executable(name: "BonjourClientTest", targets: [ "BonjourClientTest" ])
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0"),
    ],
    targets: [
        .target(name: "BonjourClientTest", dependencies: [ "RobologsRemote" ], path: "Sources.BonjourClientTest"),
        .target(name: "Robologs", dependencies: [], path: "Sources.Robologs"),
        .target(
            name: "RobologsRemote",
            dependencies: [ "Robologs", "SwiftProtobuf" ],
            path: "Sources.Robologs.Remote",
            exclude: [ "Transports/ProtoHttpRemoteLoggerTransport/proto/backend.proto" ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
