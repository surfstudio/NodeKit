// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "NodeKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "NodeKit",
            targets: ["NodeKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("5.0.0-beta.6")),
        .package(url: "https://github.com/surfstudio/CoreEvents", .branch("add-swiftpm-support")),
    ],
    targets: [
        .target(
            name: "NodeKit",
            dependencies: [
                "Alamofire",
                "CoreEvents",
            ],
            path: "NodeKit",
            exclude: [
                "Info.plist",
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "NodeKit",
                "Alamofire",
                "CoreEvents"
            ],
            path: "IntegrationTests",
            exclude: [
                "Info.plist",
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
