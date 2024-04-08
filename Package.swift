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
            targets: ["NodeKit"]),
    ],
    dependencies: [
        .package(url: "./ThirdParty")
    ],
    targets: [
        .target(
            name: "NodeKit",
            dependencies: [
                "ThirdParty"
            ],
            path: "NodeKit",
            exclude: [
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "NodeKitTests",
            dependencies: [
                "NodeKit"
            ],
            path: "NodeKitTests",
            exclude: [
                "Resources/LICENSE.txt",
            ]
        ),
    ]
)
