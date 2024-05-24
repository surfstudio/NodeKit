// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MockServer",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "MockServer",
            targets: ["MockServer"]
        )
    ],
    dependencies: [
        .package(path: "../../.."),
        .package(path: "../Models")
    ],
    targets: [
        .target(
            name: "MockServer",
            dependencies: [
                "NodeKit",
                "Models"
            ],
            path: "MockServer"
        )
    ]
)
