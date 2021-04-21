// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Robologs",
    platforms: [ .iOS(.v11), .macOS(.v11) ],
    products: [
        .library(name: "Robologs", type: .static, targets: [ "Robologs" ]),
        .library(name: "RobologsRemote", type: .static, targets: [ "RobologsRemote" ]),
        .library(name: "RobologsServer", type: .static, targets: [ "RobologsServer" ]),
        .executable(name: "ExampleBonjourClient", targets: [ "ExampleBonjourClient" ]),
        .executable(name: "ExampleServer", targets: [ "ExampleServer" ]),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "ExampleBonjourClient", dependencies: [ "RobologsRemote" ], path: "Sources.Example.BonjourClient"),
        .target(name: "ExampleServer", dependencies: [ "RobologsServer" ], path: "Sources.Example.Server"),

        .target(name: "Robologs", dependencies: [], path: "Sources.Robologs"),
        .target(
            name: "RobologsRemote",
            dependencies: [ "Robologs", "SwiftProtobuf", "Starscream" ],
            path: "Sources.Robologs.Remote",
            exclude: [ "Transports/ProtoHttpRemoteLoggerTransport/proto/backend.proto" ]
        ),
        .target(
            name: "RobologsServer",
            dependencies: [
                "RobologsRemote",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
            ],
            path: "Sources.Robologs.Server",
            exclude: [ "Transports/ProtoHttpRemoteLoggerTransport/proto/backend.proto" ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
