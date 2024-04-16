// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        )
    ],
    dependencies: [
        .package(path: "../../NodeKit")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                "NodeKit"
            ],
            path: "Models"
        )
    ]
)
