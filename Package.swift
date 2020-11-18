// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BMPlayer",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "BMPlayer",
            targets: ["BMPlayer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit"),
    ],
    targets: [
        .target(
            name: "BMPlayer",
            path: "Source",
            exclude: [
                "Info.plist",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
