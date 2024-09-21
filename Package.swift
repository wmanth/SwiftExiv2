// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftExiv2",
    platforms: [.macOS(.v10_15), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftExiv2",
            targets: ["SwiftExiv2"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CxxExiv2",
            exclude: [
                "exiv2/src/CMakeLists.txt",
                "exiv2/src/doxygen.hpp.in",
                "exiv2/src/meson.build",
                "exiv2/src/TODO",
                "exiv2/xmpsdk/src/UnicodeInlines.incl_cpp"],
            sources: [
                "ImageProxy.cpp",
                "exiv2/src",
                "exiv2/xmpsdk/src"],
            cxxSettings: [
                .headerSearchPath("exiv2/include"),
                .headerSearchPath("exiv2/include/exiv2"),
                .headerSearchPath("exiv2/xmpsdk/include")]),
        .target(
            name: "SwiftExiv2",
            dependencies: ["CxxExiv2"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(
            name: "SwiftExiv2Tests",
            dependencies: ["SwiftExiv2", .product(name: "Numerics", package: "swift-numerics")],
            resources: [.copy("Test Assets")],
            swiftSettings: [.interoperabilityMode(.Cxx)])
    ],
    cxxLanguageStandard: .cxx17
)
