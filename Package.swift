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
		.package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
		.package(name: "NVActivityIndicatorView", url: "https://github.com/ninjaprox/NVActivityIndicatorView", from: "5.1.1")
    ],
    targets: [
		.target(
            name: "BMPlayer",
			dependencies: ["SnapKit", "NVActivityIndicatorView"],
            path: "Source",
            exclude: [
                "Info.plist"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
