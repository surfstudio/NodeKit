// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "NodeKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NodeKit",
            targets: ["NodeKit"]),
        .library(name: "NodeKitBSON",
                 targets: ["NodeKitBSON"])
    ],
    dependencies: [
        .package(url: "https://github.com/surfstudio/CoreEvents", .exact("2.0.2")),
        .package(url: "https://github.com/OpenKitten/BSON.git", .exact("8.0.9"))
    ],
    targets: [
        .target(
            name: "NodeKit",
            dependencies: [
                "CoreEvents"
            ],
            path: "NodeKit",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "NodeKitBSON",
            dependencies: [
                "NodeKit",
                "BSON"
            ],
            path: "NodeKitBson"
        ),
        .testTarget(
            name: "NodeKitTests",
            dependencies: [
                "NodeKit",
                "CoreEvents"
            ],
            path: "NodeKitTests",
            exclude: [
                "Resources/LICENSE.txt",
                // TODO: - Переписать тесты на блекбокс - убрать завязку на сервер
                "FormUrlCodingTests.swift",
                "MultipartRequestTests.swift",
                "SimpleURLChainTests.swift",
                "TestEmptyResponseMapping.swift"
            ]
        ),
    ]
)
