// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-macros",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MacrosInterface",
            targets: ["MacrosInterface"]
        )
    ],
    dependencies: [
        // Depend on the Swift 5.10 release of SwiftSyntax
        //        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main")
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "510.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Implementation"
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "MacrosInterface",
            dependencies: ["MacrosImplementation"],
            path: "Sources/Interface"
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "MacrosExe",
            dependencies: ["MacrosInterface"],
            path: "Sources/Exe"
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MacrosImplementationTests",
            dependencies: [
                "MacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/ImplementationTests"
        )
    ]
)
