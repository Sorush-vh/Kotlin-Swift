// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "masterMind",
    products: [
        .executable(name: "masterMind", targets: ["masterMind"])
    ],
    targets: [
        .executableTarget(
            name: "masterMind"
        )
    ]
)
