// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WhereIsMyMouse",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "WhereIsMyMouse", targets: ["WhereIsMyMouse"])],
    targets: [
        .target(name: "MouseCore"),
        .executableTarget(name: "WhereIsMyMouse", dependencies: ["MouseCore"]),
        // Standalone checks also run with Command Line Tools (no XCTest/Xcode needed).
        .executableTarget(name: "MouseCoreChecks", dependencies: ["MouseCore"], path: "Tests/MouseCoreTests")
    ]
)
