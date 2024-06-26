// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Services",
            targets: ["Services"]
        )
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../MockServer"),
        .package(path: "../../..")
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: [
                "Models",
                "NodeKit",
                "MockServer"
            ],
            path: "Services"
        )
    ]
)
