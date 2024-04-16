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
        .package(path: "./NodeKitThirdParty")
    ],
    targets: [
        .target(
            name: "NodeKit",
            dependencies: [
                "NodeKitThirdParty"
            ],
            path: "NodeKit",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "NodeKitMock",
            dependencies: [
                "NodeKit"
            ],
            path: "NodeKitMock"
        ),
        .testTarget(
            name: "NodeKitTests",
            dependencies: [
                "NodeKit",
                "NodeKitMock"
            ],
            path: "NodeKitTests",
            exclude: [
                "Resources/LICENSE.txt",
            ]
        ),
    ]
)
