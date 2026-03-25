// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OsimaticCoreIos",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "OsimaticCoreIos", targets: ["OsimaticCoreIos"]),
    ],
    targets: [
        .target(name: "OsimaticCoreIos", path: "Sources"),
    ]
)