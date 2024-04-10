// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NodeKitThirdParty",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "NodeKitThirdParty",
            targets: ["NodeKitThirdParty"]
        )
    ],
    targets: [
        .target(
            name: "NodeKitThirdParty",
            path: "Source",
            cSettings: [
                .define("BUILD_LIBRARY_FOR_DISTRIBUTION", to: "YES")
            ]
        )
    ]
)
