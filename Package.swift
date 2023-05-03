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
        .package(url: "https://github.com/surfstudio/CoreEvents", .exact("2.0.2"))
    ],
    targets: [
        .target(
            name: "NodeKit",
            dependencies: [
                "CoreEvents",
            ],
            path: "NodeKit",
            exclude: [
                "Info.plist",
            ]
        ),
        .testTarget(
            name: "NodeKitTests",
            dependencies: [
                "NodeKit",
                "Alamofire",
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
