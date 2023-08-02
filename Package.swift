// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift
// required to build this package.

import PackageDescription

let package = Package(
    name: "yahtml2pdf",
    platforms: [.macOS(.v13)],
    dependencies: [
      .package(
        url: "https://github.com/apple/swift-argument-parser.git",
        from: "1.2.2")
    ],
    targets: [
        .executableTarget(
            name: "yahtml2pdf",
            dependencies: [
              .product(
                name: "ArgumentParser", package: "swift-argument-parser")],
            path: "Sources")
    ]
)
