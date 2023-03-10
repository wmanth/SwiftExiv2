// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftExiv2",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftExiv2",
            targets: ["Exiv2"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "exiv2lib",
            exclude: [
                "library/src/exiv2.cpp",
                "library/src/actions.cpp",
                "library/src/getopt.cpp",
                "library/src/utils.cpp"],
            sources: [
                "library/src",
                "library/xmpsdk/src"],
            cxxSettings: [
                .headerSearchPath("library/include/exiv2"),
                .headerSearchPath("library/xmpsdk/include"),
                .unsafeFlags([
                    "-Wno-shorten-64-to-32",
                    "-Wno-unused-command-line-argument"])]),
        .target(
            name: "Exiv2",
            dependencies: ["exiv2lib"],
            cxxSettings: [
                .headerSearchPath("../exiv2lib/library/include")]),
        .testTarget(
            name: "SwiftExiv2Tests",
            dependencies: ["Exiv2"],
            resources: [.copy("Assets")],
            linkerSettings: [
                .linkedLibrary("expat"),
                .linkedLibrary("iconv"),
                .linkedLibrary("z")])
    ]
)
