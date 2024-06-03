// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NodeKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "NodeKit",
            targets: ["NodeKit"]
        ),
        .library(
            name: "NodeKitMock",
            targets: ["NodeKitMock"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NodeKitThirdParty",
            path: "NodeKit/NodeKitThirdParty/Source"
        ),
        .target(
            name: "NodeKit",
            dependencies: [
                "NodeKitThirdParty"
            ],
            path: "NodeKit/NodeKit",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "NodeKitMock",
            dependencies: [
                "NodeKit"
            ],
            path: "NodeKit/NodeKitMock"
        ),
        .testTarget(
            name: "NodeKitTests",
            dependencies: [
                "NodeKit",
                "NodeKitMock"
            ],
            path: "NodeKit/NodeKitTests",
            exclude: [
                "Resources/LICENSE.txt",
            ]
        ),
    ]
)
