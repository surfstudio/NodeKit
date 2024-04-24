// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ThirdParty",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ThirdParty",
            targets: ["ThirdParty"]),
    ],
    targets: [
        .target(
            name: "ThirdParty",
            path: "Source"
        )
    ]
)
